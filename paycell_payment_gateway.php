<?php
/**
 * Paycell Payment Gateway Module
 * 
 * @author    Paycell <info@paycell.com.tr>
 * @copyright 2025 Paycell
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

use PrestaShop\PrestaShop\Core\Payment\PaymentOption;

class Paycell_Payment_Gateway extends PaymentModule
{
    const HOOKS = [
        'displayOrderConfirmation',
        'paymentOptions',
    ];

    const CONFIG_SANDBOX_MODE = 'PAYCELL_SANDBOX_MODE';
    const CONFIG_APPLICATION_NAME = 'PAYCELL_APPLICATION_NAME';
    const CONFIG_APPLICATION_PASSWORD = 'PAYCELL_APPLICATION_PASSWORD';
    const CONFIG_SECURE_CODE = 'PAYCELL_SECURE_CODE';
    const CONFIG_MERCHANT_CODE = 'PAYCELL_MERCHANT_CODE';

    protected $_postErrors = [];

    /**
     * {@inheritdoc}
     */
    public function __construct()
    {
        $this->name = 'paycell_payment_gateway';
        $this->tab = 'payments_gateways';
        $this->author = 'Paycell';
        $this->version = '1.0.0';
        $this->need_instance = 1;
        $this->ps_versions_compliancy = ['min' => '1.7.6.0', 'max' => _PS_VERSION_];
        $this->controllers = ['validation', 'callback', 'bininfo'];
        $this->currencies = true;
        $this->currencies_mode = 'checkbox';

        parent::__construct();

        $this->displayName = $this->trans('Paycell Payment Gateway', [], 'Modules.Paycellpaymentgateway.Admin');
        $this->description = $this->trans('Accept payments through Paycell payment gateway.', [], 'Modules.Paycellpaymentgateway.Admin');
        $this->confirmUninstall = $this->trans('Are you sure you want to uninstall this payment module?', [], 'Modules.Paycellpaymentgateway.Admin');

        if (!Configuration::get(self::CONFIG_APPLICATION_NAME) || !Configuration::get(self::CONFIG_APPLICATION_PASSWORD) || !Configuration::get(self::CONFIG_SECURE_CODE) || !Configuration::get(self::CONFIG_MERCHANT_CODE)) {
            $this->warning = $this->trans('Paycell configuration is required before using this module.', [], 'Modules.Paycellpaymentgateway.Admin');
        }
    }

    /**
     * {@inheritdoc}
     */
    public function install()
    {
        return parent::install()
            && (bool) $this->registerHook(static::HOOKS)
            && $this->installConfiguration();
    }

    /**
     * Opt-in to the new translation system
     */
    public function isUsingNewTranslationSystem()
    {
        return true;
    }

    /**
     * {@inheritdoc}
     */
    public function uninstall()
    {
        return Configuration::deleteByName(self::CONFIG_SANDBOX_MODE)
            && Configuration::deleteByName(self::CONFIG_APPLICATION_NAME)
            && Configuration::deleteByName(self::CONFIG_APPLICATION_PASSWORD)
            && Configuration::deleteByName(self::CONFIG_SECURE_CODE)
            && Configuration::deleteByName(self::CONFIG_MERCHANT_CODE)
            && parent::uninstall();
    }

    /**
     * Install default configuration
     */
    private function installConfiguration()
    {
        return Configuration::updateValue(self::CONFIG_SANDBOX_MODE, true);
    }


    /**
     * Get module configuration page
     */
    public function getContent()
    {
        $output = '';

        if (Tools::isSubmit('btnSubmit')) {
            $this->_postValidation();
            if (!count($this->_postErrors)) {
                $this->_postProcess();
                $output .= $this->displayConfirmation($this->trans('Settings updated', [], 'Admin.Notifications.Success'));
            } else {
                foreach ($this->_postErrors as $err) {
                    $output .= $this->displayError($err);
                }
            }
        }

        $output .= $this->displayForm();

        return $output;
    }

    /**
     * Validate configuration form
     */
    private function _postValidation()
    {
        if (Tools::isSubmit('btnSubmit')) {
            if (!Tools::getValue(self::CONFIG_APPLICATION_NAME)) {
                $this->_postErrors[] = $this->trans('Application Name is required.', [], 'Modules.Paycellpaymentgateway.Admin');
            }
            if (!Tools::getValue(self::CONFIG_APPLICATION_PASSWORD)) {
                $this->_postErrors[] = $this->trans('Application Password is required.', [], 'Modules.Paycellpaymentgateway.Admin');
            }
            if (!Tools::getValue(self::CONFIG_SECURE_CODE)) {
                $this->_postErrors[] = $this->trans('Secure Code is required.', [], 'Modules.Paycellpaymentgateway.Admin');
            }
            if (!Tools::getValue(self::CONFIG_MERCHANT_CODE)) {
                $this->_postErrors[] = $this->trans('Merchant Code is required.', [], 'Modules.Paycellpaymentgateway.Admin');
            }
        }
    }

    /**
     * Process configuration form
     */
    private function _postProcess()
    {
        if (Tools::isSubmit('btnSubmit')) {
            Configuration::updateValue(self::CONFIG_SANDBOX_MODE, (bool) Tools::getValue(self::CONFIG_SANDBOX_MODE));
            Configuration::updateValue(self::CONFIG_APPLICATION_NAME, Tools::getValue(self::CONFIG_APPLICATION_NAME));
            Configuration::updateValue(self::CONFIG_APPLICATION_PASSWORD, Tools::getValue(self::CONFIG_APPLICATION_PASSWORD));
            Configuration::updateValue(self::CONFIG_SECURE_CODE, Tools::getValue(self::CONFIG_SECURE_CODE));
            Configuration::updateValue(self::CONFIG_MERCHANT_CODE, Tools::getValue(self::CONFIG_MERCHANT_CODE));
        }
    }

    /**
     * Display configuration form
     */
    public function displayForm()
    {
        $fields_form = [
            'form' => [
                'legend' => [
                    'title' => $this->trans('Paycell Configuration', [], 'Modules.Paycellpaymentgateway.Admin'),
                    'icon' => 'icon-cogs',
                ],
                'input' => [
                    [
                        'type' => 'switch',
                        'label' => $this->trans('Sandbox Mode', [], 'Modules.Paycellpaymentgateway.Admin'),
                        'name' => self::CONFIG_SANDBOX_MODE,
                        'is_bool' => true,
                        'desc' => $this->trans('Enable sandbox mode for testing', [], 'Modules.Paycellpaymentgateway.Admin'),
                        'values' => [
                            [
                                'id' => 'active_on',
                                'value' => true,
                                'label' => $this->trans('Yes', [], 'Admin.Global'),
                            ],
                            [
                                'id' => 'active_off',
                                'value' => false,
                                'label' => $this->trans('No', [], 'Admin.Global'),
                            ],
                        ],
                    ],
                    [
                        'type' => 'text',
                        'label' => $this->trans('Application Name', [], 'Modules.Paycellpaymentgateway.Admin'),
                        'name' => self::CONFIG_APPLICATION_NAME,
                        'required' => true,
                        'desc' => $this->trans('Your Paycell application name', [], 'Modules.Paycellpaymentgateway.Admin'),
                    ],
                    [
                        'type' => 'password',
                        'label' => $this->trans('Application Password', [], 'Modules.Paycellpaymentgateway.Admin'),
                        'name' => self::CONFIG_APPLICATION_PASSWORD,
                        'required' => true,
                        'desc' => $this->trans('Your Paycell application password', [], 'Modules.Paycellpaymentgateway.Admin'),
                    ],
                    [
                        'type' => 'password',
                        'label' => $this->trans('Secure Code', [], 'Modules.Paycellpaymentgateway.Admin'),
                        'name' => self::CONFIG_SECURE_CODE,
                        'required' => true,
                        'desc' => $this->trans('Your Paycell secure code', [], 'Modules.Paycellpaymentgateway.Admin'),
                    ],
                    [
                        'type' => 'text',
                        'label' => $this->trans('Merchant Code', [], 'Modules.Paycellpaymentgateway.Admin'),
                        'name' => self::CONFIG_MERCHANT_CODE,
                        'required' => true,
                        'desc' => $this->trans('Your Paycell merchant code', [], 'Modules.Paycellpaymentgateway.Admin'),
                    ],
                ],
                'submit' => [
                    'title' => $this->trans('Save', [], 'Admin.Actions'),
                ],
            ],
        ];

        $helper = new HelperForm();
        $helper->show_toolbar = false;
        $helper->table = $this->table;
        $helper->module = $this;
        $helper->default_form_language = $this->context->language->id;
        $helper->allow_employee_form_lang = Configuration::get('PS_BO_ALLOW_EMPLOYEE_FORM_LANG') ?: 0;
        $helper->identifier = $this->identifier;
        $helper->submit_action = 'btnSubmit';
        $helper->currentIndex = $this->context->link->getAdminLink('AdminModules', false) . '&configure=' . $this->name . '&tab_module=' . $this->tab . '&module_name=' . $this->name;
        $helper->token = Tools::getAdminTokenLite('AdminModules');
        $helper->tpl_vars = [
            'fields_value' => $this->getConfigFieldsValues(),
            'languages' => $this->context->controller->getLanguages(),
            'id_language' => $this->context->language->id,
        ];

        return $helper->generateForm([$fields_form]);
    }

    /**
     * Get configuration field values
     */
    public function getConfigFieldsValues()
    {
        return [
            self::CONFIG_SANDBOX_MODE => Tools::getValue(self::CONFIG_SANDBOX_MODE, Configuration::get(self::CONFIG_SANDBOX_MODE)),
            self::CONFIG_APPLICATION_NAME => Tools::getValue(self::CONFIG_APPLICATION_NAME, Configuration::get(self::CONFIG_APPLICATION_NAME)),
            self::CONFIG_APPLICATION_PASSWORD => Tools::getValue(self::CONFIG_APPLICATION_PASSWORD, Configuration::get(self::CONFIG_APPLICATION_PASSWORD)),
            self::CONFIG_SECURE_CODE => Tools::getValue(self::CONFIG_SECURE_CODE, Configuration::get(self::CONFIG_SECURE_CODE)),
            self::CONFIG_MERCHANT_CODE => Tools::getValue(self::CONFIG_MERCHANT_CODE, Configuration::get(self::CONFIG_MERCHANT_CODE)),
        ];
    }

    /**
     * Hook for payment options
     */
    public function hookPaymentOptions(array $params)
    {
        if (empty($params['cart'])) {
            return [];
        }

        /** @var Cart $cart */
        $cart = $params['cart'];

        if (!$this->checkCurrency($cart)) {
            return [];
        }

        $paycellOption = new PaymentOption();
        $paycellOption->setModuleName($this->name);
        $paycellOption->setCallToActionText($this->trans('Pay with Paycell', [], 'Modules.Paycellpaymentgateway.Shop'));
        $paycellOption->setForm($this->generateEmbeddedForm());
        $paycellOption->setLogo($this->context->link->getBaseLink() . 'modules/paycell_payment_gateway/views/img/paycell-option-logo.png');
        return [$paycellOption];
    }

    private function generateEmbeddedForm()
    {
        // Prepare JavaScript translations
        $jsTranslations = [
            'fillRequiredFields' => $this->trans('Please fill in all required fields correctly', [], 'Modules.Paycellpaymentgateway.Shop'),
            'tokenizationFailed' => $this->trans('Tokenization failed', [], 'Modules.Paycellpaymentgateway.Shop'),
            'paymentProcessingFailed' => $this->trans('Payment processing failed', [], 'Modules.Paycellpaymentgateway.Shop'),
            'enterCardholderName' => $this->trans('Please enter the cardholder name', [], 'Modules.Paycellpaymentgateway.Shop'),
            'enterValidCardNumber' => $this->trans('Please enter a valid card number', [], 'Modules.Paycellpaymentgateway.Shop'),
            'enterValidExpiryDate' => $this->trans('Please enter a valid expiry date (MM/YY)', [], 'Modules.Paycellpaymentgateway.Shop'),
            'cardExpired' => $this->trans('Card has expired. Please enter a valid expiry date', [], 'Modules.Paycellpaymentgateway.Shop'),
            'enterValidCVV' => $this->trans('Please enter a valid CVV', [], 'Modules.Paycellpaymentgateway.Shop'),
            'hashGenerationFailed' => $this->trans('Failed to generate hash', [], 'Modules.Paycellpaymentgateway.Shop'),
            'singlePayment' => $this->trans('Single Payment', [], 'Modules.Paycellpaymentgateway.Shop'),
            'installments' => $this->trans('Installments', [], 'Modules.Paycellpaymentgateway.Shop'),
            // Template translations
            'cardHolderName' => $this->trans('Card Holder Name', [], 'Modules.Paycellpaymentgateway.Shop'),
            'fullNameOnCard' => $this->trans('Full name as shown on card', [], 'Modules.Paycellpaymentgateway.Shop'),
            'cardNumber' => $this->trans('Card Number', [], 'Modules.Paycellpaymentgateway.Shop'),
            'expiryDate' => $this->trans('Expiry Date', [], 'Modules.Paycellpaymentgateway.Shop'),
            'cvv' => $this->trans('CVV', [], 'Modules.Paycellpaymentgateway.Shop'),
            'installmentOptions' => $this->trans('Installment Options', [], 'Modules.Paycellpaymentgateway.Shop'),
            'processingOrder' => $this->trans('Processing your order...', [], 'Modules.Paycellpaymentgateway.Shop'),
        ];

        $this->context->smarty->assign([
            'action' => $this->context->link->getModuleLink($this->name, 'validation', ['option' => 'embedded'], true),
            'js_translations' => $jsTranslations,
        ]);
        try {
            return $this->context->smarty->fetch('module:paycell_payment_gateway/views/templates/front/paymentOptionEmbeddedForm.tpl');
        } catch (Exception $e) {
            return '';
        }
        
    }

    /**
     * Hook for order confirmation
     */
    public function hookDisplayOrderConfirmation(array $params)
    {
        /** @var Order $order */
        $order = (isset($params['objOrder'])) ? $params['objOrder'] : $params['order'];

        if (!Validate::isLoadedObject($order) || $order->module !== $this->name) {
            return '';
        }

        $this->context->smarty->assign([
            'shop_name' => $this->context->shop->name,
            'total' => $this->context->getCurrentLocale()->formatPrice($params['order']->getOrdersTotalPaid(), (new Currency($params['order']->id_currency))->iso_code),
            'reference' => $order->reference,
            'contact_url' => $this->context->link->getPageLink('contact', true),
        ]);

        return $this->fetch('module:paycell_payment_gateway/views/templates/hook/displayOrderConfirmation.tpl');
    }

    /**
     * Check if currency is supported
     */
    public function checkCurrency($cart)
    {
        $currency_order = new Currency((int) ($cart->id_currency));
        $currencies_module = $this->getCurrency((int) $cart->id_currency);

        if (is_array($currencies_module)) {
            foreach ($currencies_module as $currency_module) {
                if ($currency_order->id == $currency_module['id_currency']) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Get Paycell API configuration
     */
    public function getApiConfig()
    {
        $sandboxMode = (bool) Configuration::get(self::CONFIG_SANDBOX_MODE);
        
        return [
            'sandbox_mode' => $sandboxMode,
            'application_name' => Configuration::get(self::CONFIG_APPLICATION_NAME),
            'application_password' => Configuration::get(self::CONFIG_APPLICATION_PASSWORD),
            'secure_code' => Configuration::get(self::CONFIG_SECURE_CODE),
            'merchant_code' => Configuration::get(self::CONFIG_MERCHANT_CODE),
        ];
    }

}
