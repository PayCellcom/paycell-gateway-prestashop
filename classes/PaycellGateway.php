<?php
/**
 * Paycell Payment Gateway Class
 * 
 * @author    Paycell <info@paycell.com.tr>
 * @copyright 2025 Paycell
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

class PaycellGateway
{
    private $sandboxMode;
    private $applicationName;
    private $applicationPassword;
    private $secureCode;
    private $merchantCode;

    public function __construct($config)
    {
        $this->sandboxMode = $config['sandbox_mode'] ?? false;
        $this->applicationName = $config['application_name'] ?? '';
        $this->applicationPassword = $config['application_password'] ?? '';
        $this->secureCode = $config['secure_code'] ?? '';
        $this->merchantCode = $config['merchant_code'] ?? '';
    }

    /**
     * Generate hash data for requests
     */
    public function generateHashData($transactionId, $transactionDateTime) {
        $securityDataHash = $this->generateSecurityDataHash();
        $hashData = $this->getApplicationName() . $transactionId . $transactionDateTime . $this->getSecureCode() . $securityDataHash;
        return base64_encode(hash('sha256', strtoupper($hashData), true));
    }

    private function generateSecurityDataHash() {
        $securityData = strtoupper($this->getApplicationPassword() . $this->getApplicationName());
        return base64_encode(hash('sha256', $securityData, true));
    }

    public function getMerchantCode() {
        return $this->merchantCode;
    }

    public function getApplicationName() {
        return $this->applicationName;
    }

    private function getApplicationPassword() {
        return $this->applicationPassword;
    }

    private function getSecureCode() {
        return $this->secureCode;
    }

    public function make3DSSessionRequest($sessionData)
    {
        $requestData = [
            'merchantCode' => $sessionData['merchantCode'],
            'msisdn' => $sessionData['msisdn'],
            'amount' => $sessionData['amount'],
            'installmentCount' => (int)$sessionData['installmentCount'],
            'cardToken' => $sessionData['cardToken'],
            'cardId' => $sessionData['cardId'] ?? null,
            'transactionType' => $sessionData['transactionType'],
            'target' => $sessionData['target'],
            'requestHeader' => [
                'transactionId' => $sessionData['transactionId'],
                'transactionDateTime' => $sessionData['transactionDateTime'],
                'clientIPAddress' => $sessionData['clientIPAddress'],
                'applicationName' => $this->getApplicationName(),
                'applicationPwd' => $this->getApplicationPassword()
            ]
        ];
        
        return $this->makeRequest('/api/3d/session', $requestData);
    }

    public function make3DsSessionResultRequest($sessionData)
    {
        $requestData = [
            'merchantCode' => $this->getMerchantCode(),
            'msisdn' => $sessionData['msisdn'],
            'transactionType' => $sessionData['transactionType'],
            'threeDSessionId' => $sessionData['threeDSessionId'],
            'requestHeader' => [
                'transactionId' => $sessionData['transactionId'],
                'transactionDateTime' => $sessionData['transactionDateTime'],
                'clientIPAddress' => $sessionData['clientIPAddress'],
                'applicationName' => $this->getApplicationName(),
                'applicationPwd' => $this->getApplicationPassword()
            ]
        ];
        
        return $this->makeRequest('/api/3d/session-result', $requestData);
    }

    public function makeProvisionAllRequest($sessionData)
    {
        $requestData = [
            'paymentMethodType' => 'CREDIT_CARD',
            'merchantCode' => $this->getMerchantCode(),
            'msisdn' => $sessionData['msisdn'],
            'referenceNumber' => $sessionData['transactionNumber'],
            'amount' => $sessionData['amount'],
            'currency' => 'TRY',
            'installmentCount' => $sessionData['installmentCount'],
            'paymentType' => 'SALE',
            'threeDSessionId' => $sessionData['threeDSessionId'],
            'cardToken' => $sessionData['cardToken'] ?? null,
            'cardId' => $sessionData['cardId'] ?? null,
            'requestHeader' => [
                'transactionId' => $sessionData['transactionId'],
                'transactionDateTime' => $sessionData['transactionDateTime'],
                'clientIPAddress' => $sessionData['clientIPAddress'],
                'applicationName' => $this->getApplicationName(),
                'applicationPwd' => $this->getApplicationPassword()
            ]
        ];
        
        return $this->makeRequest('/api/payment/provision', $requestData);
    }

    public function makeInquireAllRequest($sessionData)
    {
        $requestData = [
            'requestHeader' => [
                'transactionId' => $sessionData['transactionId'],
                'transactionDateTime' => $sessionData['transactionDateTime'],
                'clientIPAddress' => $sessionData['clientIPAddress'],
                'applicationName' => $this->getApplicationName(),
                'applicationPwd' => $this->getApplicationPassword()
            ],
            'msisdn' => $sessionData['msisdn'],
            'merchantCode' => $this->getMerchantCode(),
            'originalReferenceNumber' => $sessionData['referenceNumber'],
            'paymentMethodType' => $sessionData['paymentMethodType'],
            'referenceNumber' => $sessionData['referenceNumber'],
        ];
        
        return $this->makeRequest('/api/payment/inquire', $requestData);
    }

    public function makeBinCheckRequest($sessionData)
    {
        $requestData = [
            'requestHeader' => [
                'transactionId' => $sessionData['transactionId'],
                'transactionDateTime' => $sessionData['transactionDateTime'],
                'clientIPAddress' => $sessionData['clientIPAddress'],
                'applicationName' => $this->getApplicationName(),
                'applicationPwd' => $this->getApplicationPassword()
            ],
            'binValue' => $sessionData['binNumber'],
            'merchantCode' => $this->getMerchantCode(),
        ];
        
        return $this->makeRequest('/api/cards/bin-info', $requestData);
    }

    private function getBaseUrl()
    {
        if ($this->sandboxMode) {
            return 'https://plugin-wp-test.paycell.com.tr';
        } else {
            return 'https://plugin-wp-prod.paycell.com.tr';
        }
    }

    public function base64url_decode($data) {
        return base64_decode(strtr($data, '-_', '+/'));
    }

    public function base64url_encode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private function makeRequest($endpoint, $data = null, $method = 'POST')
    {
        $url = $this->getBaseUrl() . $endpoint;
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Accept: application/json'
        ]);

        if ($method === 'POST' && $data) {
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            throw new \Exception('CURL Error: ' . $error);
        }

        if ($httpCode !== 200) {
            throw new \Exception('HTTP Error: ' . $httpCode);
        }

        $responseData = json_decode($response, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new \Exception('Invalid JSON response from Paycell API');
        }

        return $responseData;
    }

    public function completeOrder($module, $currency, $customer, $cartId)
    {
        try {
            $cart = new Cart($cartId);
            if (!Validate::isLoadedObject($cart)) {
                return false;
            }
            $order = new Order(Order::getIdByCartId($cart->id));
            if (Validate::isLoadedObject($order)) {
                return false;
            }
            $module->validateOrder(
                $cart->id,
                Configuration::get('PS_OS_PAYMENT'),
                $cart->getOrderTotal(true, Cart::BOTH),
                $module->displayName,
                null,
                [],
                $currency->id,
                false,
                $customer->secure_key
            );

            $order = new Order(Order::getIdByCartId($cart->id));
            if (!Validate::isLoadedObject($order)) {
                return false;
            }

            return $order;
        } catch (\Exception $e) {
            return false;
        }
    }

}
