<?php
/**
 * Paycell Payment Gateway Callback Controller
 * 
 * @author    Paycell <info@paycell.com.tr>
 * @copyright 2025 Paycell
 */

class Paycell_Payment_GatewayCallbackModuleFrontController extends ModuleFrontController
{
    public function postProcess()
    {
        $input = Tools::getAllValues();
        require_once $this->module->getLocalPath() . 'classes/PaycellGateway.php';
        $gateway = new PaycellGateway($this->module->getApiConfig());
        $compressedCallbackData = $gateway->base64url_decode($input['transaction']);
        $callbackData = json_decode(gzuncompress($compressedCallbackData), true);
        $transactionHash = $gateway->generateHashData($callbackData['transactionId'], $callbackData['transactionDateTime']);
        $orderHash = $gateway->generateHashData($callbackData['orderId'], $callbackData['amount']);
        if ($transactionHash !== $callbackData['transactionHash'] || $orderHash !== $callbackData['orderHash']) {
            $this->context->controller->errors[] = 'Invalid transaction hash or order hash';
            $this->redirectWithNotifications('index.php?controller=order');
            return;
        }
        try {
            $result = $gateway->make3DsSessionResultRequest($callbackData);
            if (($result['mdStatus'] == 1 || $result['mdStatus'] == 'Y') && $result['threeDOperationResult']['threeDResult'] == 0) {
                $provisionResult = $gateway->makeProvisionAllRequest($callbackData);
                if (($provisionResult['responseHeader']['responseCode'] ?? false)  == 0 && $provisionResult['approvalCode'] ?? false && $provisionResult['orderId'] ?? false ) {
                    $completeOrder = $gateway->completeOrder($this->module, $this->context->currency, $this->context->customer, $callbackData['orderId']);
                    if ($completeOrder) {
                        Tools::redirect($this->context->link->getPageLink(
                            'order-confirmation',
                            true,
                            (int) $this->context->language->id,
                            [
                                'id_cart' => (int) $this->context->cart->id,
                                'id_module' => (int) $this->module->id,
                                'id_order' => (int) $completeOrder->id,
                                'key' => $this->context->customer->secure_key,
                            ]
                        ));
                        return;
                    }
                    $this->context->controller->errors[] = 'Unexpected error occurred while completing order';
                    $this->redirectWithNotifications('index.php?controller=order');
                    return;
                } else if (($provisionResult['responseHeader']['responseCode'] ?? false) == 2012) {
                    $inquireAllResult = $gateway->makeInquireAllRequest([
                        'transactionId' => $callbackData['transactionId'],
                        'transactionDateTime' => $callbackData['transactionDateTime'],
                        'clientIPAddress' => $callbackData['clientIPAddress'],
                        'msisdn' => $callbackData['msisdn'],
                        'referenceNumber' => $callbackData['transactionNumber'],
                        'paymentMethodType' => 'CREDIT_CARD',
                    ]);
                    if (($inquireAllResult['responseHeader']['responseCode'] ?? false) == 0 && $inquireAllResult['orderId'] ?? false) {
                        $completeOrder = $gateway->completeOrder($this->module, $this->context->currency, $this->context->customer, $callbackData['orderId']);
                        if ($completeOrder) {
                            Tools::redirect($this->context->link->getPageLink(
                                'order-confirmation',
                                true,
                                (int) $this->context->language->id,
                                [
                                    'id_cart' => (int) $this->context->cart->id,
                                    'id_module' => (int) $this->module->id,
                                    'id_order' => (int) $completeOrder->id,
                                    'key' => $this->context->customer->secure_key,
                                ]
                            ));
                            return;
                        }
                        $this->context->controller->errors[] = 'Unexpected error occurred while completing order';
                        $this->redirectWithNotifications('index.php?controller=order');
                        return;
                    } else {
                        $this->context->controller->errors[] = $inquireAllResult['responseHeader']['responseDescription'];
                        $this->redirectWithNotifications('index.php?controller=order');
                        return;
                    }
                } else {
                    $this->context->controller->errors[] = $provisionResult['responseHeader']['responseDescription'];
                    $this->redirectWithNotifications('index.php?controller=order');
                    return;
                }
            } else {
                $this->context->controller->errors[] = $result['mdErrorMessage'] ?? $result['responseHeader']['responseDescription'];
                $this->redirectWithNotifications('index.php?controller=order');
                return;
            }
        } catch (\Exception $e) {
            $this->context->controller->errors[] = $e->getMessage();
            $this->redirectWithNotifications('index.php?controller=order');
            return;
        }
    }
}
