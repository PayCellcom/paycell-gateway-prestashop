<?php
/**
 * Paycell Payment Gateway Validation Controller
 * 
 * @author    Paycell <info@paycell.com.tr>
 * @copyright 2025 Paycell
 */

class Paycell_Payment_GatewayValidationModuleFrontController extends ModuleFrontController
{
    public $ssl = true;

    public function initContent()
    {
        parent::initContent();
        $input = json_decode(file_get_contents('php://input'), true);
        // Handle hash generation request
        if (isset($input['action']) && $input['action'] === 'generate_hash') {
            $this->generateHash($input['transaction_id'], $input['transaction_time']);
            return;
        }

        $option = Tools::getValue('option');
        
        if ($option === 'embedded') {
            $this->processEmbeddedPayment();
        } else {
            Tools::redirect('index.php?controller=order');
        }
    }

    private function getClientIPAddress()
    {
        $ipKeys = ['HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP', 'HTTP_CLIENT_IP', 'REMOTE_ADDR'];
        
        foreach ($ipKeys as $key) {
            if (!empty($_SERVER[$key])) {
                $ip = $_SERVER[$key];
                if (strpos($ip, ',') !== false) {
                    $ip = trim(explode(',', $ip)[0]);
                }
                if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
                    return $ip;
                }
            }
        }
        
        return $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
    }

    private function generateHash($transactionId, $transactionDateTime)
    {
        if (!isset($_SERVER['HTTP_X_REQUESTED_WITH']) || 
            strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) !== 'xmlhttprequest') {
            $this->sendJsonResponse(false, 'Invalid request');
            return;
        }

        try {
            require_once $this->module->getLocalPath() . 'classes/PaycellGateway.php';
            $gateway = new PaycellGateway($this->module->getApiConfig());
            
            $hash = $gateway->generateHashData($transactionId, $transactionDateTime);
            
            $this->sendJsonResponse(true, 'Hash generated successfully', [
                'hash' => $hash,
                'transaction_id' => $transactionId,
                'transaction_datetime' => $transactionDateTime,
                'application_name' => $gateway->getApplicationName(),
            ]);
        } catch (Exception $e) {
            $this->sendJsonResponse(false, 'Hash generation error: ' . $e->getMessage());
        }
    }

    private function processEmbeddedPayment()
    {
        $input = Tools::getAllValues();
        $cart = $this->context->cart;
        $addressDetails = new Address($cart->id_address_invoice);
        $phone = $addressDetails->phone;
        $customer = $this->context->customer;
        $currency = $this->context->currency;

        if (!$cart->id || !$customer->id) {
            $this->errors[] = $this->trans('Invalid cart or customer.', [], 'Modules.Paycellpaymentgateway.Shop');
            return;
        }

        $cardToken = $input['card_token'];
        if (empty($cardToken)) {
            $this->errors[] = $this->trans('Card token is required.', [], 'Modules.Paycellpaymentgateway.Shop');
            return;
        }
        require_once $this->module->getLocalPath() . 'classes/PaycellGateway.php';
        $gateway = new PaycellGateway($this->module->getApiConfig());
        $sessionData = [
            'cardToken' => $cardToken,
            'orderId' => $cart->id,
            'amount' => round(round((float)$cart->getOrderTotal(true, Cart::BOTH), 2) * 100, 0),
            'installmentCount' => (int)($input['installmentCount'] ?? 1),
            'transactionType' => 'AUTH',
            'target' => 'MERCHANT',
            'msisdn' => $phone ?? null,
            'transactionId' => $input['transaction_id'],
            'transactionDateTime' => $input['transaction_time'],
            'transactionNumber' => $input['transaction_number'],
            'clientIPAddress' => $this->getClientIPAddress(),
            'merchantCode' => $gateway->getMerchantCode(),
            'applicationName' => $gateway->getApplicationName(),
        ];

        $transactionHash = $gateway->generateHashData($sessionData['transactionId'], $sessionData['transactionDateTime']);
        $orderHash = $gateway->generateHashData($sessionData['orderId'], $sessionData['amount']);

        $sessionData['transactionHash'] = $transactionHash;
        $sessionData['orderHash'] = $orderHash;

        $response = $gateway->make3DSSessionRequest($sessionData);

        if ($response && isset($response['responseHeader']['responseCode']) && $response['responseHeader']['responseCode'] == '0') {
            $threeDSessionId = $response['threeDSessionId'] ?? null;
            $sandboxMode = true;
            if ($sandboxMode) {
                $threeDSecureUrl = 'https://omccstb.turkcell.com.tr/paymentmanagement/rest/threeDSecure';
            } else {
                $threeDSecureUrl = 'https://epayment.turkcell.com.tr/paymentmanagement/rest/threeDSecure';
            }
            if ($threeDSessionId && $threeDSecureUrl) {
                $sessionData['threeDSessionId'] = $threeDSessionId;
                $serializedTransactionData = json_encode($sessionData);
                $compressedTransactionData = gzcompress($serializedTransactionData, 9);
                $encodedTransactionData = $gateway->base64url_encode($compressedTransactionData);
                $callbackUrl = $this->context->link->getModuleLink($this->module->name, 'callback', ['transaction' => $encodedTransactionData], true);
                
                $this->context->smarty->assign([
                    'threeDSecureUrl' => $threeDSecureUrl,
                    'sessionId' => $threeDSessionId,
                    'callbackUrl' => $callbackUrl,
                ]);
                
                $this->setTemplate('module:paycell_payment_gateway/views/templates/front/threeds.tpl');
                return;
            } else {
                throw new \Exception('Invalid 3DS session response - missing session ID or secure URL');
            }
        } else {
            Tools::redirect('index.php?controller=order');
            return;
        }
    }


    private function sendJsonResponse($success, $message, $data = [])
    {
        header('Content-Type: application/json');
        echo json_encode([
            'success' => $success,
            'message' => $message,
            'data' => $data
        ]);
        exit;
    }
}
