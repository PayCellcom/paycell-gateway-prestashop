<?php
/**
 * Paycell Payment Gateway Saved Cards Controller
 * 
 * @author    Paycell <info@paycell.com.tr>
 * @copyright 2025 Paycell
 */

class Paycell_Payment_GatewaySavedcardsModuleFrontController extends ModuleFrontController
{
    public $ssl = true;

    public function initContent()
    {
        parent::initContent();
        
        if (!isset($_SERVER['HTTP_X_REQUESTED_WITH']) || 
            strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) !== 'xmlhttprequest') {
            $this->sendJsonResponse(false, 'Invalid request');
            return;
        }

        $token = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? null;

        if (!$token || $token != Tools::getToken(false)) {
            $this->sendJsonResponse(false, 'Invalid CSRF token');
            return;
        }

        if (!$this->context->customer->isLogged()) {
            $this->sendJsonResponse(false, 'Customer must be logged in');
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true);
        $action = $input['action'] ?? Tools::getValue('action');

        try {
            require_once $this->module->getLocalPath() . 'classes/PaycellGateway.php';
            $gateway = new PaycellGateway($this->module->getApiConfig());
            
            $cart = $this->context->cart;
            $addressDetails = new Address($cart->id_address_invoice);
            $msisdn = $addressDetails->phone;

            if (!$msisdn) {
                $this->sendJsonResponse(false, 'Phone number is required');
                return;
            }

            $transactionId = $this->generateTransactionId();
            $transactionDateTime = $this->generateTransactionTime();

            if ($action === 'get') {
                $sessionData = [
                    'transactionId' => $transactionId,
                    'transactionDateTime' => $transactionDateTime,
                    'clientIPAddress' => $this->getClientIPAddress(),
                    'msisdn' => $msisdn
                ];
                
                if (isset($input['otpToken']) && !empty($input['otpToken'])) {
                    $sessionData['otpToken'] = $input['otpToken'];
                }
                
                $response = $gateway->getSavedCards($sessionData);
                
                if ($response && isset($response['responseHeader']['responseCode'])) {
                    $responseCode = $response['responseHeader']['responseCode'];
                    if ($responseCode == '3110' || $responseCode == 3110 || (isset($response['responseHeader']['responseDescription']) && 
                        (stripos($response['responseHeader']['responseDescription'], 'otp') !== false || 
                         stripos($response['responseHeader']['responseDescription'], 'verification') !== false))) {
                        $this->sendJsonResponse(false, 'OTP verification required', [
                            'requiresOTP' => true, 
                            'cards' => []
                        ]);
                        return;
                    }
                    
                    if ($responseCode == '0') {
                        $cards = [];
                        
                        $cardsData = null;
                        if (isset($response['paymentMethods']) && is_array($response['paymentMethods'])) {
                            $cardsData = $response['paymentMethods'];
                        } elseif (isset($response['cards']) && is_array($response['cards'])) {
                            $cardsData = $response['cards'];
                        } elseif (isset($response['cardList']) && is_array($response['cardList'])) {
                            $cardsData = $response['cardList'];
                        } elseif (isset($response['data']['paymentMethods']) && is_array($response['data']['paymentMethods'])) {
                            $cardsData = $response['data']['paymentMethods'];
                        } elseif (isset($response['data']['cards']) && is_array($response['data']['cards'])) {
                            $cardsData = $response['data']['cards'];
                        } elseif (isset($response['data']['cardList']) && is_array($response['data']['cardList'])) {
                            $cardsData = $response['data']['cardList'];
                        }
                        
                        if ($cardsData) {
                            foreach ($cardsData as $card) {
                                $cards[] = [
                                    'cardId' => $card['cardId'] ?? $card['id'] ?? null,
                                    'id' => $card['cardId'] ?? $card['id'] ?? null,
                                    'alias' => $card['alias'] ?? null,
                                    'maskedCardNumber' => $card['maskedCardNo'] ?? $card['maskedCardNumber'] ?? $card['maskedCard'] ?? null,
                                    'maskedCardNo' => $card['maskedCardNo'] ?? $card['maskedCardNumber'] ?? $card['maskedCard'] ?? null,
                                    'cardBrand' => $card['cardBrand'] ?? null,
                                    'cardType' => $card['cardType'] ?? null,
                                    'isDefault' => $card['isDefault'] ?? false,
                                    'isExpired' => $card['isExpired'] ?? false,
                                    'expiryMonth' => $card['expiryMonth'] ?? null,
                                    'expiryYear' => $card['expiryYear'] ?? null,
                                ];
                            }
                        }
                        
                        $this->sendJsonResponse(true, 'Cards retrieved successfully', ['cards' => $cards]);
                    } else {
                        $errorMessage = $response['responseHeader']['responseDescription'] ?? 
                                       $response['errorMessage'] ?? 
                                       $response['message'] ?? 
                                       'Failed to retrieve cards';
                        $this->sendJsonResponse(false, $errorMessage, ['cards' => []]);
                    }
                } else {
                    $this->sendJsonResponse(false, 'Invalid response from Paycell API', ['cards' => []]);
                }
            } elseif ($action === 'send_otp') {
                $sessionData = [
                    'transactionId' => $transactionId,
                    'transactionDateTime' => $transactionDateTime,
                    'clientIPAddress' => $this->getClientIPAddress(),
                    'msisdn' => $msisdn
                ];
                
                if (isset($input['referenceNumber']) && !empty($input['referenceNumber'])) {
                    $sessionData['referenceNumber'] = $input['referenceNumber'];
                }
                
                $response = $gateway->sendOtp($sessionData);
                
                if ($response && isset($response['responseHeader']['responseCode'])) {
                    $responseCode = $response['responseHeader']['responseCode'];
                    if ($responseCode == '0') {
                        $this->sendJsonResponse(true, 'OTP sent successfully', [
                            'otpToken' => $response['token'] ?? null,
                            'remainingRetryCount' => $response['remainingRetryCount'] ?? null
                        ]);
                    } else {
                        $errorMessage = $response['responseHeader']['responseDescription'] ?? 
                                       $response['errorMessage'] ?? 
                                       $response['message'] ?? 
                                       'Failed to send OTP';
                        $this->sendJsonResponse(false, $errorMessage);
                    }
                } else {
                    $this->sendJsonResponse(false, 'Invalid response from Paycell API');
                }
            } elseif ($action === 'verify_otp') {
                if (!isset($input['otpCode']) || empty($input['otpCode'])) {
                    $this->sendJsonResponse(false, 'OTP code is required');
                    return;
                }
                
                if (!isset($input['otpToken']) || empty($input['otpToken'])) {
                    $this->sendJsonResponse(false, 'OTP token is required');
                    return;
                }
                
                $sessionData = [
                    'transactionId' => $transactionId,
                    'transactionDateTime' => $transactionDateTime,
                    'clientIPAddress' => $this->getClientIPAddress(),
                    'msisdn' => $msisdn,
                    'otpCode' => $input['otpCode'],
                    'otpToken' => $input['otpToken']
                ];
                
                if (isset($input['referenceNumber']) && !empty($input['referenceNumber'])) {
                    $sessionData['referenceNumber'] = $input['referenceNumber'];
                }
                
                $response = $gateway->verifyOtp($sessionData);
                
                if ($response && isset($response['responseHeader']['responseCode'])) {
                    $responseCode = $response['responseHeader']['responseCode'];
                    if ($responseCode == '0') {
                            $cardsSessionData = [
                                'transactionId' => $this->generateTransactionId(),
                                'transactionDateTime' => $this->generateTransactionTime(),
                                'clientIPAddress' => $this->getClientIPAddress(),
                                'msisdn' => $msisdn,
                                'referenceNumber' => $input['referenceNumber'],
                            ];
                            
                            $cardsResponse = $gateway->getSavedCards($cardsSessionData);
                            
                            if ($cardsResponse && isset($cardsResponse['responseHeader']['responseCode']) && $cardsResponse['responseHeader']['responseCode'] == '0') {
                                $cards = [];
                                $cardsData = null;
                                if (isset($cardsResponse['paymentMethods']) && is_array($cardsResponse['paymentMethods'])) {
                                    $cardsData = $cardsResponse['paymentMethods'];
                                } elseif (isset($cardsResponse['cards']) && is_array($cardsResponse['cards'])) {
                                    $cardsData = $cardsResponse['cards'];
                                } elseif (isset($cardsResponse['cardList']) && is_array($cardsResponse['cardList'])) {
                                    $cardsData = $cardsResponse['cardList'];
                                } elseif (isset($cardsResponse['data']['paymentMethods']) && is_array($cardsResponse['data']['paymentMethods'])) {
                                    $cardsData = $cardsResponse['data']['paymentMethods'];
                                } elseif (isset($cardsResponse['data']['cards']) && is_array($cardsResponse['data']['cards'])) {
                                    $cardsData = $cardsResponse['data']['cards'];
                                } elseif (isset($cardsResponse['data']['cardList']) && is_array($cardsResponse['data']['cardList'])) {
                                    $cardsData = $cardsResponse['data']['cardList'];
                                }
                                
                                if ($cardsData) {
                                    foreach ($cardsData as $card) {
                                        $cards[] = [
                                            'cardId' => $card['cardId'] ?? $card['id'] ?? null,
                                            'id' => $card['cardId'] ?? $card['id'] ?? null,
                                            'alias' => $card['alias'] ?? null,
                                            'maskedCardNumber' => $card['maskedCardNo'] ?? $card['maskedCardNumber'] ?? $card['maskedCard'] ?? null,
                                            'maskedCardNo' => $card['maskedCardNo'] ?? $card['maskedCardNumber'] ?? $card['maskedCard'] ?? null,
                                            'cardBrand' => $card['cardBrand'] ?? null,
                                            'cardType' => $card['cardType'] ?? null,
                                            'isDefault' => $card['isDefault'] ?? false,
                                            'isExpired' => $card['isExpired'] ?? false,
                                            'expiryMonth' => $card['expiryMonth'] ?? null,
                                            'expiryYear' => $card['expiryYear'] ?? null,
                                        ];
                                    }
                                }
                                
                                $this->sendJsonResponse(true, 'OTP verified successfully', [
                                    'otpToken' => $otpToken,
                                    'cards' => $cards
                                ]);
                            } else {
                                $this->sendJsonResponse(false, 'Failed to retrieve cards after OTP verification');
                        }
                    } else {
                        $errorMessage = $response['responseHeader']['responseDescription'] ?? 
                                       $response['errorMessage'] ?? 
                                       $response['message'] ?? 
                                       'Invalid OTP code';
                        $remainingRetryCount = $response['remainingRetryCount'] ?? 0;
                        $this->sendJsonResponse(false, $errorMessage, [
                            'remainingRetryCount' => $remainingRetryCount ?? 0
                        ]);
                    }
                } else {
                    $this->sendJsonResponse(false, 'Invalid response from Paycell API');
                }
            } else {
                $this->sendJsonResponse(false, 'Invalid action');
            }
        } catch (Exception $e) {
            $this->sendJsonResponse(false, 'Error: ' . $e->getMessage());
        }
    }

    private function generateTransactionId()
    {
        $timestamp = (string)(time() * 1000);
        $random = str_pad((string)rand(0, 9999999), 7, '0', STR_PAD_LEFT);
        return $timestamp . $random;
    }

    private function generateTransactionTime()
    {
        $now = new DateTime();
        return $now->format('YmdHis') . str_pad((string)$now->format('v'), 3, '0', STR_PAD_LEFT);
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

    private function sendJsonResponse($success, $message, $data = [])
    {
        header('Content-Type: application/json');
        echo json_encode([
            'success' => $success,
            'message' => Tools::safeOutput((string) $message),
            'data' => $data
        ]);
        exit;
    }
}

