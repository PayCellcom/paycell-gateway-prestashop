<?php
/**
 * Paycell Payment Gateway BIN Info Controller
 * 
 * @author    Paycell <info@paycell.com.tr>
 * @copyright 2025 Paycell
 */

class Paycell_Payment_GatewayBininfoModuleFrontController extends ModuleFrontController
{
    public $ssl = true;

    public function initContent()
    {
        parent::initContent();
        
        // Check if this is an AJAX request
        if (!isset($_SERVER['HTTP_X_REQUESTED_WITH']) || 
            strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) !== 'xmlhttprequest') {
            $this->sendJsonResponse(false, 'Invalid request');
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!$input || !isset($input['transactionId']) || !isset($input['transactionDateTime']) || !isset($input['binNumber'])) {
            $this->sendJsonResponse(false, 'Missing required parameters');
            return;
        }

        try {
            require_once $this->module->getLocalPath() . 'classes/PaycellGateway.php';
            $gateway = new PaycellGateway($this->module->getApiConfig());
            
            $sessionData = [
                'transactionId' => $input['transactionId'],
                'transactionDateTime' => $input['transactionDateTime'],
                'clientIPAddress' => $this->getClientIPAddress(),
                'binNumber' => $input['binNumber']
            ];
            
            $response = $gateway->makeBinCheckRequest($sessionData);
            if ($response && isset($response['responseHeader']['responseCode']) && $response['responseHeader']['responseCode'] == '0') {
                if (isset($response['cardBinInformations']) && count($response['cardBinInformations']) > 0) {
                    $cardInfo = $response['cardBinInformations'][0];
                    $isCreditCard = $cardInfo['cardType'] === 'Credit Card';
                    
                    $this->sendJsonResponse(true, 'BIN check successful', [
                        'cardType' => $cardInfo['cardType'],
                        'cardBrand' => $cardInfo['cardBrand'],
                        'cardOrganization' => $cardInfo['cardOrganization'],
                        'bankName' => $cardInfo['bankName'],
                        'isCreditCard' => $isCreditCard,
                        'canInstallment' => $isCreditCard,
                    ]);
                } else {
                    $this->sendJsonResponse(false, 'No card information found for this BIN');
                }
            } else {
                $this->sendJsonResponse(false, $response['responseHeader']['responseDescription'] ?? 'BIN check failed');
            }
        } catch (Exception $e) {
            $this->sendJsonResponse(false, 'BIN check error: ' . $e->getMessage());
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
