{**
 * Paycell Payment Gateway Embedded Form Template
 * 
 * @author    Paycell <info@paycell.com.tr>
 * @copyright 2025 Paycell
 *}

<form id="js-paycell-payment-form">
  <input type="hidden" name="option" value="embedded">
  <input type="hidden" name="card_token" id="card_token" value="">
  <input type="hidden" name="card_id" id="card_id" value="">
  <input type="hidden" name="save_card" id="save_card" value="0">

  {if $is_logged}
  <!-- Payment Option Tabs -->
  <div class="payment-option-tabs" id="payment-option-tabs" style="display: none;">
    <div class="payment-option-tab" data-tab="saved-cards">
      {$js_translations.savedCards|default:'Saved Cards'}
    </div>
    <div class="payment-option-tab active" data-tab="new-card">
      {$js_translations.useNewCard|default:'New Card'}
    </div>
  </div>

  <!-- Saved Cards Content -->
  <div class="payment-option-content" id="saved-cards-content">
    <div class="saved-cards-section">
      <div id="cards-loading" style="display: none; text-align: center; padding: 20px;">
        <div class="paycell-spinner"></div>
        <p>Loading saved cards...</p>
      </div>
      <div id="cards-error" style="display: none; color: #dc3545; padding: 10px; background: #f8d7da; border-radius: 4px; margin-bottom: 10px;"></div>
      <div class="saved-cards-list" id="saved-cards-list" style="display: none;">
        <div class="cards-container" id="cards-container"></div>
      </div>
    </div>
  </div>
  {/if}

  <!-- New Card Content -->
  <div class="payment-option-content active" id="new-card-content">
  <!-- OTP Verification Section (matching OpenCart) -->
  <div class="otp-section" id="otp-section" style="display: none;">
    <button type="button" id="btn-toggle-otp" class="otp-toggle-button">
      <span id="otp-toggle-text">{$js_translations.otpRequired|default:'You can use the credit cards that are saved in Paycell to pay for your order'}</span>
      <span id="otp-toggle-icon" class="otp-toggle-icon">▼</span>
    </button>
    <div id="otp-expanded-content" class="otp-expanded-content" style="display: none;">
      <p style="margin: 0 0 15px 0;">{$js_translations.otpMessageFull|default:'To use your cards that are saved in Paycell you must validate your phone number via OTP'}</p>
      
      <div id="otp-send-section" class="otp-send-section">
        <button type="button" id="btn-send-otp" class="btn-otp-send">{$js_translations.sendOtp|default:'Send OTP Code'}</button>
      </div>
      
      <div id="otp-verify-section" class="otp-verify-section" style="display: none;">
        <label for="otp-code" class="otp-code-label">{$js_translations.enterOtp|default:'Enter OTP Code'}</label>
          <input type="text" id="otp-code" class="otp-code-input" placeholder="{$js_translations.otpPlaceholder|default:'Enter OTP code'}" maxlength="6" pattern="[0-9]*" autocomplete="one-time-code">
          <div id="otp-message" class="otp-message"></div>
          <button type="button" id="btn-resend-otp" class="btn-otp-resend" style="display: none;">{$js_translations.resendOtp|default:'Resend OTP Code'}</button>
          <button type="button" id="btn-verify-otp" class="btn-otp-verify">{$js_translations.verifyOtp|default:'Verify OTP Code'}</button>
      </div>
      
      <div id="otp-success-message" class="otp-success-message" style="display: none;">
        {$js_translations.otpVerifiedSuccess|default:'Phone number validated successfully!'}
      </div>
      
      <div id="otp-loading" class="otp-loading" style="display: none; text-align: center; padding: 10px;">
        <div class="paycell-spinner" style="margin: 0 auto;"></div>
        <span style="display: block; margin-top: 5px;">{$js_translations.processing|default:'Processing...'}</span>
      </div>
    </div>
  </div>
  <div class="form-group">
    <label class="form-control-label" for="cardHolder">{$js_translations.cardHolderName|default:'Card Holder Name'}</label>
    <input type="text" name="cardHolder" id="cardHolder" class="form-control" placeholder="{$js_translations.fullNameOnCard|default:'Full name as shown on card'}" autocomplete="cc-name" required>
  </div>

  <div class="form-group">
    <label class="form-control-label" for="cardNumber">{$js_translations.cardNumber|default:'Card Number'}</label>
    <input type="text" name="cardNumber" id="cardNumber" class="form-control" placeholder="1234 5678 9012 3456" autocomplete="cc-number" maxlength="19" required>
  </div>

  <div class="row">
    <div class="form-group col-xs-6">
      <label class="form-control-label" for="cardExpiry">{$js_translations.expiryDate|default:'Expiry Date'}</label>
      <input type="text" name="cardExpiry" id="cardExpiry" class="form-control" placeholder="MM/YY" autocomplete="cc-exp" maxlength="5" required>
    </div>

    <div class="form-group col-xs-6">
      <label class="form-control-label" for="cardCVC">{$js_translations.cvv|default:'CVV'}</label>
      <input type="text" name="cardCVC" id="cardCVC" class="form-control" placeholder="123" autocomplete="cc-csc" maxlength="4" required>
    </div>
  </div>

<!-- 
  {if $is_logged}
  <div class="form-group">
    <div class="form-check">
      <input type="checkbox" name="saveCardCheckbox" id="saveCardCheckbox" style="margin-right: 5px;">
      <label for="saveCardCheckbox" style="font-weight: normal; margin-left: 5px;">{$js_translations.saveCard|default:'Save this card for future purchases'}</label>
    </div>
  </div>
  {/if} -->
  </div>
  <div class="form-group" id="installment-group" style="display: none;">
    <label class="form-control-label" for="installmentCount">{$js_translations.installmentOptions|default:'Installment Options'}</label>
    <select name="installmentCount" id="installmentCount" class="form-control">
      <option value="1">{$js_translations.singlePayment|default:'Single Payment'}</option>
    </select>
  </div>
</form>

<!-- Spinner wrapper -->
<div id="paycellSpinnerWrapper" class="paycell-spinner-wrapper" style="display: none;">
  <div class="paycell-spinner"></div>
  <span class="processing-order-text">{$js_translations.processingOrder|default:'Processing your order...'}</span>
</div>

<style>
.form-group {
  margin-bottom: 15px;
}

.form-control-label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #333;
}

.form-control {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.form-control:focus {
  border-color: #007bff;
  outline: 0;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.form-control.error {
  border-color: #dc3545;
  box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
}

.row {
  display: flex;
  margin: 0 -10px;
}

.col-xs-6 {
  flex: 0 0 50%;
  padding: 0 10px;
}

#cardNumber {
  letter-spacing: 1px;
}

#cardExpiry {
  text-align: center;
}

#cardCVC {
  text-align: center;
}

.btn-primary {
  background-color: #007bff;
  border-color: #007bff;
  padding: 12px 20px;
  font-size: 16px;
  width: 100%;
}

.btn-primary:disabled {
  background-color: #6c757d;
  border-color: #6c757d;
  cursor: not-allowed;
}

.error-message {
  color: #dc3545;
  font-size: 14px;
  margin-top: 5px;
}

.paycell-spinner-wrapper {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
}

.paycell-spinner {
  width: 20px;
  height: 20px;
  border: 3px solid #007cba;
  border-top: 2px solid transparent;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.processing-order-text {
  color: #007cba;
  font-size: 16px;
}

/* Installment Options Styles */
#installment-group {
  transition: all 0.3s ease;
}

#installmentCount {
  background-color: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 10px 12px;
  font-size: 14px;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

#installmentCount:focus {
  border-color: #007bff;
  outline: 0;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

#installmentCount:disabled {
  background-color: #f8f9fa;
  border-color: #e9ecef;
  color: #6c757d;
  cursor: not-allowed;
  opacity: 0.6;
}

/* Loading state for BIN check */
.bin-checking {
  opacity: 0.6;
  pointer-events: none;
}

.bin-checking::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 20px;
  height: 20px;
  margin: -10px 0 0 -10px;
  border: 2px solid #007bff;
  border-top: 2px solid transparent;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

/* Payment Option Tabs */
.payment-option-tabs {
  display: flex;
  border-bottom: 2px solid #e0e0e0;
  margin-bottom: 20px;
}

.payment-option-tab {
  flex: 1;
  padding: 12px 20px;
  text-align: center;
  cursor: pointer;
  background: #f5f5f5;
  border: none;
  border-bottom: 3px solid transparent;
  font-size: 14px;
  font-weight: 500;
  color: #666;
  transition: all 0.3s ease;
}

.payment-option-tab:hover {
  background: #e9e9e9;
  color: #333;
}

.payment-option-tab.active {
  background: #fff;
  color: #0073aa;
  border-bottom-color: #0073aa;
  font-weight: 600;
}

.payment-option-content {
  display: none;
}

.payment-option-content.active {
  display: block;
}

/* Saved Cards Section */
.saved-cards-section {
  margin-bottom: 20px;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}

.cards-container {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 15px;
  margin-top: 15px;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
  overflow: hidden;
}

@media (max-width: 600px) {
  .cards-container {
    grid-template-columns: 1fr;
  }
}

.saved-card-item {
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  background: linear-gradient(to right top, #033e8c, #4cc8d9);
  color: white;
  position: relative;
  overflow: hidden;
  aspect-ratio: 1.986;
  min-width: 0;
  max-width: 100%;
  box-sizing: border-box;
}

.saved-card-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.saved-card-item.selected {
  border: 2px solid #0073aa;
  box-shadow: 0 4px 12px rgba(0, 115, 170, 0.3);
  transform: translateY(-2px);
}

.saved-card-item .card-checkmark {
  position: absolute;
  top: 10px;
  right: 10px;
  background: #0073aa;
  color: white;
  border-radius: 50%;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: bold;
}

.saved-card-item .card-header {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 20px;
  background: none;
  border: none;
}

.saved-card-item .card-brand {
  font-size: 12px;
  text-transform: uppercase;
  opacity: 0.9;
  font-weight: 500;
}

.saved-card-item .card-type {
  font-size: 12px;
  text-transform: uppercase;
  opacity: 0.9;
  font-weight: 500;
}

.saved-card-item .card-number {
  font-size: 18px;
  font-weight: bold;
  letter-spacing: 2px;
  color: white;
  display: block;
  margin-top: 10px;
}

/* OTP Section Styles (matching OpenCart exactly) */
.otp-section {
  display: none;
  margin-bottom: 20px;
  border: 1px solid #b8daff;
  border-radius: 4px;
  background-color: #cce5ff;
}

.otp-section.active {
  display: block;
}

.otp-toggle-button {
  width: 100%;
  padding: 12px 15px;
  border: none;
  background: transparent;
  text-align: left;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
  font-weight: 500;
  color: #004085;
}

.otp-toggle-icon {
  font-size: 18px;
  transition: transform 0.3s ease;
}

.otp-expanded-content {
  display: none;
  padding: 0 15px 15px 15px;
  font-size: 14px;
  color: #004085;
  border-top: 1px solid #b8daff;
  padding-top: 15px;
}

.otp-expanded-content.active {
  display: block;
}

.otp-send-section {
  margin-bottom: 10px;
}

.btn-otp-send {
  padding: 10px 20px;
  background-color: #0073aa;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  width: 100%;
  margin-bottom: 10px;
  opacity: 1;
  transition: opacity 0.3s;
}

.btn-otp-send:hover {
  background-color: #005a87;
}

.btn-otp-send:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.otp-verify-section {
  display: none;
}

.otp-verify-section.active {
  display: block;
}

.otp-code-label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
}

.otp-code-input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  box-sizing: border-box;
  margin-bottom: 10px;
}

.otp-message {
  margin-bottom: 10px;
  font-size: 12px;
}

.btn-otp-verify {
  padding: 10px 20px;
  background-color: #0073aa;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  width: 100%;
  opacity: 1;
  transition: opacity 0.3s;
}

.btn-otp-verify:hover {
  background-color: #005a87;
}

.btn-otp-verify:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-otp-resend {
  padding: 8px 16px;
  background-color: transparent;
  color: #0073aa;
  border: 1px solid #0073aa;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 500;
  width: 100%;
  margin-bottom: 10px;
  opacity: 1;
  transition: opacity 0.3s;
}

.btn-otp-resend:hover {
  background-color: #f0f7ff;
}

.btn-otp-resend:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.otp-success-message {
  display: none;
  color: #28a745;
  font-size: 14px;
  font-weight: 500;
  margin-top: 10px;
}

.otp-success-message.active {
  display: block;
}

.otp-loading {
  text-align: center;
  padding: 10px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
}
</style>

<script>
var paycellTranslations = {
  fillRequiredFields: '{$js_translations.fillRequiredFields|escape:'javascript'}',
  tokenizationFailed: '{$js_translations.tokenizationFailed|escape:'javascript'}',
  paymentProcessingFailed: '{$js_translations.paymentProcessingFailed|escape:'javascript'}',
  enterCardholderName: '{$js_translations.enterCardholderName|escape:'javascript'}',
  enterValidCardNumber: '{$js_translations.enterValidCardNumber|escape:'javascript'}',
  enterValidExpiryDate: '{$js_translations.enterValidExpiryDate|escape:'javascript'}',
  cardExpired: '{$js_translations.cardExpired|escape:'javascript'}',
  enterValidCVV: '{$js_translations.enterValidCVV|escape:'javascript'}',
  hashGenerationFailed: '{$js_translations.hashGenerationFailed|escape:'javascript'}',
  singlePayment: '{$js_translations.singlePayment|escape:'javascript'}',
  installments: '{$js_translations.installments|escape:'javascript'}',
  savedCards: '{$js_translations.savedCards|escape:'javascript'}',
  useSavedCard: '{$js_translations.useSavedCard|escape:'javascript'}',
  useNewCard: '{$js_translations.useNewCard|escape:'javascript'}',
  saveCard: '{$js_translations.saveCard|escape:'javascript'}',
  otpRequired: '{$js_translations.otpRequired|escape:'javascript'}',
  otpMessageFull: '{$js_translations.otpMessageFull|escape:'javascript'}',
  sendOtp: '{$js_translations.sendOtp|escape:'javascript'}',
  enterOtp: '{$js_translations.enterOtp|escape:'javascript'}',
  otpPlaceholder: '{$js_translations.otpPlaceholder|escape:'javascript'}',
  resendOtp: '{$js_translations.resendOtp|escape:'javascript'}',
  verifyOtp: '{$js_translations.verifyOtp|escape:'javascript'}',
  otpVerifiedSuccess: '{$js_translations.otpVerifiedSuccess|escape:'javascript'}',
  sendingOtp: '{$js_translations.sendingOtp|escape:'javascript'}',
  failedSendOtp: '{$js_translations.failedSendOtp|escape:'javascript'}',
  verifyingOtp: '{$js_translations.verifyingOtp|escape:'javascript'}',
  invalidOtp: '{$js_translations.invalidOtp|escape:'javascript'}',
  failedValidateOtp: '{$js_translations.failedValidateOtp|escape:'javascript'}',
  otpRequiredMessage: '{$js_translations.otpRequiredMessage|escape:'javascript'}',
  processing: '{$js_translations.processing|escape:'javascript'}',
  otpSentSuccess: '{$js_translations.otpSentSuccess|default:'OTP code has been sent to your phone number.'|escape:'javascript'}',
  maxRetryAttemptsReached: '{$js_translations.maxRetryAttemptsReached|default:'Maximum retry attempts reached.'|escape:'javascript'}',
  remainingAttempts: '{$js_translations.remainingAttempts|default:'Remaining attempts:'|escape:'javascript'}',
  failedLoadCards: '{$js_translations.failedLoadCards|default:'Failed to load saved cards'|escape:'javascript'}',
  networkError: '{$js_translations.networkError|default:'Network error:'|escape:'javascript'}',
  otpVerifiedNoCards: '{$js_translations.otpVerifiedNoCards|default:'OTP verified but no cards received'|escape:'javascript'}'
};

var getCardsUrl = '{$get_cards_url|escape:'javascript'}';
var savedCards = [];
var selectedCardId = null;
var cardTokenUrl = '{$card_token_url|escape:'javascript'}';

document.addEventListener('DOMContentLoaded', function() {
  if (document.body.id !== 'checkout') {
    return;
  }
  
  let radioButtons = document.querySelectorAll('input[name="payment-option"]');
  let $paymentForm = document.querySelector('#js-paycell-payment-form');
  let $placeOrderButton = document.querySelector('#payment-confirmation button[type="submit"]');
  let paymentFormInput = document.querySelector('input[data-module-name="paycell_payment_gateway"]');
  let label = paymentFormInput !== null ? paymentFormInput.parentElement.parentElement : null;

  if (radioButtons.length === 1 && paymentFormInput) {
    $paymentForm.addEventListener("submit", handleSubmit);
    initialize();
    showInstallmentOptionsDisabled();
    $placeOrderButton.addEventListener('click', handleClick);
    {if $is_logged}
    setupTabs();
    loadSavedCards();
    {/if}
  } else {
    radioButtons.forEach(function (input) {
      input.addEventListener("change", function() {
        if(input.dataset.moduleName === 'paycell_payment_gateway' && input.checked && $paymentForm) {
          $paymentForm.addEventListener("submit", handleSubmit);
          initialize();
          showInstallmentOptionsDisabled();
          $placeOrderButton.addEventListener('click', handleClick);
          {if $is_logged}
          setupTabs();
          loadSavedCards();
          {/if}
        } else {
          $placeOrderButton.removeEventListener('click', handleClick);
        }
      });
      if(input.dataset.moduleName === 'paycell_payment_gateway' && input.checked && $paymentForm) {
        showInstallmentOptionsDisabled();
        $placeOrderButton.addEventListener('click', handleClick);
        {if $is_logged}
        setupTabs();
        loadSavedCards();
        {/if}
      }
    })
  }

  let oneButtonChecked = false;
  for(const button of radioButtons) {
    if (button.checked) {
      oneButtonChecked = true;
    }
  }

  if (!oneButtonChecked && paymentFormInput) {
    paymentFormInput.click();
  }
});

function generateTransactionId() {
    const timestamp = Date.now().toString();
    const array = new Uint32Array(1);
    crypto.getRandomValues(array);
    const random = (array[0] % 1e7).toString().padStart(7, '0');
    const transactionId = timestamp + random;
    return transactionId;
}

function generateTransactionNumber() {
  const numberTimestamp = Date.now().toString();
  const array = new Uint32Array(1);
  crypto.getRandomValues(array);
  const numberRandom = (array[0] % 1e7).toString().padStart(7, '0');
  const transactionNumber = numberTimestamp + numberRandom;
  return transactionNumber;
}

function generateReferenceNumber() {
  const numberTimestamp = Date.now().toString();
  const array = new Uint32Array(1);
  crypto.getRandomValues(array);
  const numberRandom = (array[0] % 1e7).toString().padStart(7, '0');
  const referenceNumber = numberTimestamp + numberRandom;
  return referenceNumber;
}

function generateTransactionTime() {
    const now = new Date();
    const formatted = now.getFullYear().toString() +
    String(now.getMonth() + 1).padStart(2, '0') +
    String(now.getDate()).padStart(2, '0') +
    String(now.getHours()).padStart(2, '0') +
    String(now.getMinutes()).padStart(2, '0') +
    String(now.getSeconds()).padStart(2, '0') +
    String(now.getMilliseconds()).padStart(3, '0');
    return formatted;
}

function handleClick(e) {
  e.preventDefault();
  e.stopPropagation();
  e.stopImmediatePropagation();
  
  let $paymentForm = document.querySelector('#js-paycell-payment-form');
  let $placeOrderButton = document.querySelector('#payment-confirmation button[type="submit"]');
  let $SpinnerWrapper = document.getElementById('paycellSpinnerWrapper');
  
  $placeOrderButton.setAttribute("disabled", "disabled");
  $SpinnerWrapper.style.display = 'flex';
  
  $paymentForm.dispatchEvent(new Event('submit'));
}

function initialize() {
  const cardNumber = document.getElementById('cardNumber');
  if (cardNumber) {
    let binCheckTimeout;
    
    cardNumber.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\s/g, '').replace(/[^0-9]/gi, '');
      let formattedValue = value.match(/.{ldelim}1,4{rdelim}/g);
      if (formattedValue) {
        formattedValue = formattedValue.join(' ');
      } else {
        formattedValue = value;
      }
      if (formattedValue !== value) {
        e.target.value = formattedValue;
      }
      
      clearTimeout(binCheckTimeout);
      
      if (value.length >= 6) {
        binCheckTimeout = setTimeout(() => {
          checkBinInfo(value.substring(0, 6));
        }, 500);
      } else {
        showInstallmentOptionsDisabled();
      }
    });
  }

  const cardExpiry = document.getElementById('cardExpiry');
  if (cardExpiry) {
    cardExpiry.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\D/g, '');
      if (value.length >= 2) {
        value = value.substring(0, 2) + '/' + value.substring(2, 4);
      }
      e.target.value = value;
    });
    
    cardExpiry.addEventListener('blur', function(e) {
      const value = e.target.value;
      {literal}
      if (value && !/^(0[1-9]|1[0-2])\/(\d{2})$/.test(value)) {
        {/literal}
        e.target.classList.add('error');
      } else {
        e.target.classList.remove('error');
      }
    });
  }

  const cardCVC = document.getElementById('cardCVC');
  if (cardCVC) {
    cardCVC.addEventListener('input', function(e) {
      e.target.value = e.target.value.replace(/[^0-9]/g, '');
    });
  }
}

async function handleSubmit(e) {
  e.preventDefault();
  e.stopPropagation();
  e.stopImmediatePropagation();

  const activeTab = document.querySelector('.payment-option-tab.active');
  const isUsingSavedCard = activeTab && activeTab.dataset.tab === 'saved-cards' && selectedCardId;
  
  if (isUsingSavedCard) {
    const transactionId = generateTransactionId();
    const transactionNumber = generateTransactionNumber();
    const transactionTime = generateTransactionTime();
    
    document.getElementById('card_id').value = selectedCardId;
    
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '{$action}';
    
    const cardIdInput = document.createElement('input');
    cardIdInput.type = 'hidden';
    cardIdInput.name = 'card_id';
    cardIdInput.value = selectedCardId;
    
    const optionInput = document.createElement('input');
    optionInput.type = 'hidden';
    optionInput.name = 'option';
    optionInput.value = 'embedded';

    const transactionIdInput = document.createElement('input');
    transactionIdInput.type = 'hidden';
    transactionIdInput.name = 'transaction_id';
    transactionIdInput.value = transactionId;

    const transactionNumberInput = document.createElement('input');
    transactionNumberInput.type = 'hidden';
    transactionNumberInput.name = 'transaction_number';
    transactionNumberInput.value = transactionNumber;

    const transactionTimeInput = document.createElement('input');
    transactionTimeInput.type = 'hidden';
    transactionTimeInput.name = 'transaction_time';
    transactionTimeInput.value = transactionTime;

    const installmentCountInput = document.createElement('input');
    installmentCountInput.type = 'hidden';
    installmentCountInput.name = 'installmentCount';
    const installmentSelect = document.getElementById('installmentCount');
    installmentCountInput.value = (installmentSelect && !installmentSelect.disabled) ? installmentSelect.value : '1';
    
    form.appendChild(cardIdInput);
    form.appendChild(optionInput);
    form.appendChild(transactionIdInput);
    form.appendChild(transactionNumberInput);
    form.appendChild(transactionTimeInput);
    form.appendChild(installmentCountInput);
    document.body.appendChild(form);
    form.submit();
    return;
  }

  if (!validateForm()) {
    handleError(paycellTranslations.fillRequiredFields);
    return;
  }

  const cardData = {
    holder: document.getElementById('cardHolder').value,
    number: document.getElementById('cardNumber').value.replace(/\s/g, ''),
    expiry: document.getElementById('cardExpiry').value,
    cvv: document.getElementById('cardCVC').value
  };

  try {
    const transactionId = generateTransactionId();
    const transactionNumber = generateTransactionNumber();
    const transactionTime = generateTransactionTime();
    const token = await tokenizeCard(cardData, transactionId, transactionTime);
    
    if (token) {
      document.getElementById('card_token').value = token;
      
      const saveCardCheckbox = document.getElementById('saveCardCheckbox');
      if (saveCardCheckbox && saveCardCheckbox.checked) {
        document.getElementById('save_card').value = '1';
      }
      
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '{$action}';
      
      const tokenInput = document.createElement('input');
      tokenInput.type = 'hidden';
      tokenInput.name = 'card_token';
      tokenInput.value = token;
      
      const optionInput = document.createElement('input');
      optionInput.type = 'hidden';
      optionInput.name = 'option';
      optionInput.value = 'embedded';

      const transactionIdInput = document.createElement('input');
      transactionIdInput.type = 'hidden';
      transactionIdInput.name = 'transaction_id';
      transactionIdInput.value = transactionId;

      const transactionNumberInput = document.createElement('input');
      transactionNumberInput.type = 'hidden';
      transactionNumberInput.name = 'transaction_number';
      transactionNumberInput.value = transactionNumber;

      const transactionTimeInput = document.createElement('input');
      transactionTimeInput.type = 'hidden';
      transactionTimeInput.name = 'transaction_time';
      transactionTimeInput.value = transactionTime;

      const installmentCountInput = document.createElement('input');
      installmentCountInput.type = 'hidden';
      installmentCountInput.name = 'installmentCount';
      const installmentSelect = document.getElementById('installmentCount');
      installmentCountInput.value = (installmentSelect && !installmentSelect.disabled) ? installmentSelect.value : '1';
      
      const saveCardInput = document.createElement('input');
      saveCardInput.type = 'hidden';
      saveCardInput.name = 'save_card';
      saveCardInput.value = (saveCardCheckbox && saveCardCheckbox.checked) ? '1' : '0';
      
      form.appendChild(tokenInput);
      form.appendChild(optionInput);
      form.appendChild(transactionIdInput);
      form.appendChild(transactionNumberInput);
      form.appendChild(transactionTimeInput);
      form.appendChild(installmentCountInput);
      form.appendChild(saveCardInput);
      document.body.appendChild(form);
      form.submit();
    } else {
      handleError(paycellTranslations.tokenizationFailed);
    }
  } catch (error) {
    handleError(paycellTranslations.paymentProcessingFailed);
  }
}

function validateForm() {
  const holder = document.getElementById('cardHolder').value.trim();
  const number = document.getElementById('cardNumber').value.replace(/\s/g, '');
  const expiry = document.getElementById('cardExpiry').value;
  const cvv = document.getElementById('cardCVC').value;

  if (!holder) {
    handleError(paycellTranslations.enterCardholderName);
    return false;
  }

  if (!number || number.length < 13 || number.length > 19) {
    handleError(paycellTranslations.enterValidCardNumber);
    return false;
  }
{literal}
  if (!expiry || !/^(0[1-9]|1[0-2])\/(\d{2})$/.test(expiry)) {
    {/literal}
    handleError(paycellTranslations.enterValidExpiryDate);
    return false;
  }
  
  const [month, year] = expiry.split('/');
  const currentDate = new Date();
  const currentYear = currentDate.getFullYear() % 100;
  const currentMonth = currentDate.getMonth() + 1;
  
  const expiryYear = parseInt(year);
  const expiryMonth = parseInt(month);
  
  if (expiryYear < currentYear || (expiryYear === currentYear && expiryMonth < currentMonth)) {
    handleError(paycellTranslations.cardExpired);
    return false;
  }

  if (!cvv || cvv.length < 3 || cvv.length > 4) {
    handleError(paycellTranslations.enterValidCVV);
    return false;
  }

  return true;
}

async function tokenizeCard(cardData, transactionId, transactionTime) {
  try {
    const hashResponse = await fetch('{$action}', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-TOKEN': window.prestashop.static_token
      },
      body: JSON.stringify({
        action: 'generate_hash',
        transaction_id: transactionId,
        transaction_time: transactionTime
      })
    });
    
    const hashData = await hashResponse.json();
    
    if (!hashData.success) {
      throw new Error(paycellTranslations.hashGenerationFailed);
    }

    const cardTokenUrl = '{$card_token_url}';
    const response = await fetch(cardTokenUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        header: {
            applicationName: hashData.data.application_name,
            transactionId: transactionId,
            transactionDateTime: transactionTime,
        },
        creditCardNo: cardData.number,
        expireDateMonth: cardData.expiry.split('/')[0],
        expireDateYear: cardData.expiry.split('/')[1],
        cvcNo: cardData.cvv,
        ccAuthor: cardData.holder,
        hashData: hashData.data.hash
      })
    });

    const data = await response.json();

    if (data && data.cardToken) {
      return data.cardToken;
    } else {
      throw new Error(data.message || 'Tokenization failed');
    }
  } catch (error) {
    throw error;
  }
}

function handleError(error) {
  let $placeOrderButton = document.querySelector('#payment-confirmation button[type="submit"]');
  $placeOrderButton.removeAttribute("disabled");
  let $SpinnerWrapper = document.getElementById('paycellSpinnerWrapper');
  $SpinnerWrapper.style.display = 'none';
  
  const messageContainer = document.querySelector('#error-message');
  if (messageContainer) {
    messageContainer.textContent = error;
  } else {
    const errorDiv = document.createElement('div');
    errorDiv.id = 'error-message';
    errorDiv.className = 'error-message';
    errorDiv.textContent = error;
    errorDiv.style.color = '#dc3545';
    errorDiv.style.marginTop = '10px';
    
    const form = document.querySelector('#js-paycell-payment-form');
    if (form) {
      form.appendChild(errorDiv);
    }
  }
}

async function checkBinInfo(binNumber) {
  try {
    const transactionId = generateTransactionId();
    const transactionDateTime = generateTransactionTime();
    
    const response = await fetch('{$link->getModuleLink("paycell_payment_gateway", "bininfo", [], true)}', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-TOKEN': window.prestashop.static_token
      },
      body: JSON.stringify({
        transactionId: transactionId,
        transactionDateTime: transactionDateTime,
        binNumber: binNumber
      })
    });
    
    const data = await response.json();
    
    if (data.success) {
      if (data.data.isCreditCard) {
        showInstallmentOptions();
      } else {
        showInstallmentOptionsDisabled();
      }
    } else {
      showInstallmentOptionsDisabled();
    }
  } catch (error) {
    showInstallmentOptionsDisabled();
  }
}

function showInstallmentOptions() {
  const installmentGroup = document.getElementById('installment-group');
  const installmentSelect = document.getElementById('installmentCount');
  if (installmentGroup && installmentSelect) {
    installmentSelect.innerHTML = '';
    
    for (let i = 1; i <= 12; i++) {
      const option = document.createElement('option');
      option.value = i;
      if (i === 1) {
        option.textContent = paycellTranslations.singlePayment;
      } else {
        option.textContent = i + ' ' + paycellTranslations.installments;
      }
      installmentSelect.appendChild(option);
    }
    
    installmentSelect.disabled = false;
    installmentSelect.style.opacity = '1';
    installmentGroup.style.display = 'block';
  }
}

function showInstallmentOptionsDisabled() {
  const installmentGroup = document.getElementById('installment-group');
  const installmentSelect = document.getElementById('installmentCount');
  
  if (installmentGroup && installmentSelect) {
    installmentSelect.innerHTML = '';
    
    const option = document.createElement('option');
    option.value = '1';
    option.textContent = paycellTranslations.singlePayment;
    option.selected = true;
    installmentSelect.appendChild(option);
    
    installmentSelect.disabled = true;
    installmentSelect.style.opacity = '0.6';
    installmentGroup.style.display = 'block';
  }
}

function hideInstallmentOptions() {
 showInstallmentOptionsDisabled();
}

async function loadSavedCards() {
  const cardsLoading = document.getElementById('cards-loading');
  const cardsError = document.getElementById('cards-error');
  const savedCardsList = document.getElementById('saved-cards-list');
  
  if (cardsLoading) cardsLoading.style.display = 'block';
  if (cardsError) cardsError.style.display = 'none';
  if (savedCardsList) savedCardsList.style.display = 'none';
  
  try {
    const transactionId = generateTransactionId();
    const transactionDateTime = generateTransactionTime();
    
    const response = await fetch(getCardsUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-TOKEN': window.prestashop.static_token
      },
      body: JSON.stringify({
        action: 'get',
        transactionId: transactionId,
        transactionDateTime: transactionDateTime
      })
    });
    
    const data = await response.json();
    
    if (cardsLoading) cardsLoading.style.display = 'none';
    
    if (data.success && data.data && data.data.cards) {
      savedCards = data.data.cards;
      displaySavedCards();
    } else if (data.requiresOTP || data.data?.requiresOTP) {
      if (!otpReferenceNumber) {
        otpReferenceNumber = generateReferenceNumber();
      }
      showOtpSection();
    } else {
      if (cardsError) {
        cardsError.textContent = data.message || paycellTranslations.failedLoadCards || 'Failed to load saved cards';
        cardsError.style.display = 'block';
      }
    }
  } catch (error) {
    if (cardsLoading) cardsLoading.style.display = 'none';
    if (cardsError) {
      cardsError.textContent = (paycellTranslations.networkError || 'Network error:') + ' ' + error.message;
      cardsError.style.display = 'block';
    }
    console.error('Error loading saved cards:', error);
  }
}

function displaySavedCards() {
  const cardsContainer = document.getElementById('cards-container');
  const savedCardsList = document.getElementById('saved-cards-list');
  const paymentOptionTabs = document.getElementById('payment-option-tabs');
  const cardsLoading = document.getElementById('cards-loading');
  const cardsError = document.getElementById('cards-error');
  
  if (!cardsContainer || !savedCardsList) {
    return;
  }
  
  cardsLoading.style.display = 'none';
  cardsError.style.display = 'none';
  cardsContainer.innerHTML = '';
  
  if (savedCards.length === 0) {
    if (paymentOptionTabs) {
      paymentOptionTabs.style.display = 'none';
    }
    document.querySelectorAll('.payment-option-content').forEach(function(content) {
      content.classList.remove('active');
    });
    const newCardContent = document.getElementById('new-card-content');
    if (newCardContent) {
      newCardContent.classList.add('active');
    }
    return;
  }
  
  if (paymentOptionTabs) {
    paymentOptionTabs.style.display = 'flex';
  }
  
  savedCards.forEach(function(card, index) {
    const cardId = card.cardId || card.id || index;
    const cardNumber = card.maskedCardNumber || card.maskedCardNo || card.maskedCard || card.cardNumber || '•••• •••• •••• ••••';
    const cardBrand = card.cardBrand || 'Credit Card';
    const cardType = card.cardType || 'Card';
    const cardTypeNormalized = String(cardType).toLowerCase();
    const isCreditCard = cardTypeNormalized === 'credit';
    const isDefault = card.isDefault || false;
    const isSelected = (selectedCardId == cardId) || (isDefault && index === 0);
    
    if (isSelected && !selectedCardId) {
      selectedCardId = cardId;
    }
    
    const cardDiv = document.createElement('div');
    cardDiv.className = 'saved-card-item' + (isSelected ? ' selected' : '');
    cardDiv.dataset.cardId = String(cardId);
    if (isDefault) {
      cardDiv.dataset.default = 'true';
    }
    cardDiv.dataset.cardType = cardType;
    cardDiv.dataset.isCreditCard = isCreditCard ? '1' : '0';
    
    cardDiv.innerHTML = 
      (isSelected ? '<div class="card-checkmark">✓</div>' : '') +
      '<div class="card-header">' +
        '<div class="card-brand">' + cardBrand + '</div>' +
        '<div class="card-type">' + cardType + '</div>' +
      '</div>' +
      '<div class="card-number">' + cardNumber + '</div>';
    
    cardDiv.addEventListener('click', function() {
      handleCardSelection(cardId);
    });
    
    cardsContainer.appendChild(cardDiv);
  });
  
  savedCardsList.style.display = 'block';
  
  const defaultCard = document.querySelector('.saved-card-item[data-default="true"]');
  if (defaultCard) {
    defaultCard.click();
  } else if (cardsContainer.children.length > 0) {
    cardsContainer.children[0].click();
  }
}

function setupTabs() {
  const tabs = document.querySelectorAll('.payment-option-tab');
  
  tabs.forEach(function(tab) {
    tab.addEventListener('click', function() {
      const tabName = this.dataset.tab;
      
      tabs.forEach(function(t) {
        t.classList.remove('active');
      });
      this.classList.add('active');
      
      document.querySelectorAll('.payment-option-content').forEach(function(content) {
        content.classList.remove('active');
        content.style.display = 'none';
      });
      
      const targetContent = document.getElementById(tabName + '-content');
      if (targetContent) {
        targetContent.classList.add('active');
        targetContent.style.display = 'block';
      }

      if (tabName === 'new-card') {
        selectedCardId = null;
        document.getElementById('card_id').value = '';
        document.querySelectorAll('.saved-card-item').forEach(function(item) {
          item.classList.remove('selected');
          const checkmark = item.querySelector('.card-checkmark');
          if (checkmark) {
            checkmark.remove();
          }
        });
        hideInstallmentOptions();
      }
      
      if (tabName === 'saved-cards') {
        const savedCardsList = document.getElementById('saved-cards-list');
        if (savedCardsList && savedCards.length > 0) {
          savedCardsList.style.display = 'block';
        }
        const selectedItem = document.querySelector('.saved-card-item.selected');
        if (selectedItem) {
          const isCredit = selectedItem.dataset.isCreditCard === '1';
          if (isCredit) {
            showInstallmentOptions();
          } else {
            showInstallmentOptionsDisabled();
          }
        } else {
          hideInstallmentOptions();
        }
      }
    });
  });
}

function handleCardSelection(cardId) {
  document.querySelectorAll('.saved-card-item').forEach(function(item) {
    item.classList.remove('selected');
    const checkmark = item.querySelector('.card-checkmark');
    if (checkmark) {
      checkmark.remove();
    }
  });
  
  const selectedItem = document.querySelector('.saved-card-item[data-card-id="' + cardId + '"]');
  if (selectedItem) {
    selectedItem.classList.add('selected');
    selectedItem.insertAdjacentHTML('afterbegin', '<div class="card-checkmark">✓</div>');

    const isCredit = selectedItem.dataset.isCreditCard === '1';
    if (isCredit) {
      showInstallmentOptions();
    } else {
      showInstallmentOptionsDisabled();
    }
  }
  
  selectedCardId = cardId;
  document.getElementById('card_id').value = cardId;
  
  const savedCardsTab = document.querySelector('.payment-option-tab[data-tab="saved-cards"]');
  if (savedCardsTab && !savedCardsTab.classList.contains('active')) {
    savedCardsTab.click();
  }
}

var otpReferenceNumber = null;
var otpToken = null;
var otpSectionExpanded = false;
var otpRemainingRetryCount = null;

function showOtpSection() {
  const otpSection = document.getElementById('otp-section');
  if (otpSection) {
    otpSection.style.display = 'block';
    otpSection.classList.add('active');
  }
}

function toggleOtpSection() {
  const expandedContent = document.getElementById('otp-expanded-content');
  const toggleIcon = document.getElementById('otp-toggle-icon');
  
  if (expandedContent) {
    if (otpSectionExpanded) {
      expandedContent.style.display = 'none';
      expandedContent.classList.remove('active');
      if (toggleIcon) toggleIcon.style.transform = 'rotate(0deg)';
      otpSectionExpanded = false;
    } else {
      expandedContent.style.display = 'block';
      expandedContent.classList.add('active');
      if (toggleIcon) toggleIcon.style.transform = 'rotate(180deg)';
      otpSectionExpanded = true;
    }
  }
}

function hideOtpSection() {
  const otpSection = document.getElementById('otp-section');
  if (otpSection) {
    otpSection.style.display = 'none';
    otpSection.classList.remove('active');
    resetOtpForm();
  }
}

function resetOtpForm() {
  const otpCodeInput = document.getElementById('otp-code');
  const otpMessage = document.getElementById('otp-message');
  const otpSendSection = document.getElementById('otp-send-section');
  const otpVerifySection = document.getElementById('otp-verify-section');
  const otpSuccessMessage = document.getElementById('otp-success-message');
  
  if (otpCodeInput) otpCodeInput.value = '';
  if (otpMessage) {
    otpMessage.textContent = '';
    otpMessage.className = 'otp-message';
  }
  if (otpSendSection) otpSendSection.style.display = 'block';
  if (otpVerifySection) {
    otpVerifySection.style.display = 'none';
    otpVerifySection.classList.remove('active');
  }
  if (otpSuccessMessage) {
    otpSuccessMessage.style.display = 'none';
    otpSuccessMessage.classList.remove('active');
  }
  const otpResendBtn = document.getElementById('btn-resend-otp');
  if (otpResendBtn) otpResendBtn.style.display = 'none';
  otpSectionExpanded = false;
  otpToken = null;
  otpReferenceNumber = null;
  otpRemainingRetryCount = null;
}

async function sendOtp() {
  const otpLoading = document.getElementById('otp-loading');
  const otpMessage = document.getElementById('otp-message');
  const otpSendBtn = document.getElementById('btn-send-otp');
  const otpSendSection = document.getElementById('otp-send-section');
  const otpVerifySection = document.getElementById('otp-verify-section');
  
  if (!otpReferenceNumber) {
    otpReferenceNumber = generateReferenceNumber();
  }
  
  if (otpLoading) otpLoading.style.display = 'flex';
  if (otpMessage) {
    otpMessage.textContent = '';
    otpMessage.className = 'otp-message';
  }
  if (otpSendBtn) otpSendBtn.disabled = true;
  
  try {
    const transactionId = generateTransactionId();
    const transactionDateTime = generateTransactionTime();
    
    const response = await fetch(getCardsUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-TOKEN': window.prestashop.static_token
      },
      body: JSON.stringify({
        action: 'send_otp',
        transactionId: transactionId,
        transactionDateTime: transactionDateTime,
        referenceNumber: otpReferenceNumber
      })
    });
    
    const data = await response.json();
    
    if (otpLoading) otpLoading.style.display = 'none';
    
    if (data.success) {
      if (data.data && data.data.otpToken) {
        otpToken = data.data.otpToken;
      } else if (data.otpToken) {
        otpToken = data.otpToken;
      }
      if (data.data) {
        if (data.data.remainingRetryCount !== undefined) otpRemainingRetryCount = data.data.remainingRetryCount;
      } else if (data.remainingRetryCount !== undefined) {
        otpRemainingRetryCount = data.remainingRetryCount;
      }
      if (otpSendSection) otpSendSection.style.display = 'none';
      if (otpVerifySection) {
        otpVerifySection.style.display = 'block';
        otpVerifySection.classList.add('active');
      }
      const otpResendBtn = document.getElementById('btn-resend-otp');
      if (otpResendBtn) otpResendBtn.style.display = 'none';
      const otpVerifyBtn = document.getElementById('btn-verify-otp');
      const otpCodeInput = document.getElementById('otp-code');
      if (otpVerifyBtn) otpVerifyBtn.disabled = false;
      if (otpCodeInput) {
        otpCodeInput.disabled = false;
        otpCodeInput.value = '';
      }
      if (otpMessage) {
        otpMessage.textContent = paycellTranslations.otpSentSuccess || 'OTP code has been sent to your phone number.';
        otpMessage.className = 'otp-message success';
      }
    } else {
      if (data.data) {
        if (data.data.remainingRetryCount !== undefined) otpRemainingRetryCount = data.data.remainingRetryCount;
      } else if (data.remainingRetryCount !== undefined) {
        otpRemainingRetryCount = data.remainingRetryCount;
      }
      if (otpMessage) {
        let errorMsg = data.message || paycellTranslations.failedSendOtp || 'Failed to send OTP. Please try again.';
        if (otpRemainingRetryCount !== null && otpRemainingRetryCount <= 0) {
          errorMsg += ' ' + (paycellTranslations.maxRetryAttemptsReached || 'Maximum retry attempts reached.');
        }
        otpMessage.textContent = errorMsg;
        otpMessage.className = 'otp-message error';
      }
      if (otpSendBtn) {
        if (otpRemainingRetryCount !== null && otpRemainingRetryCount <= 0) {
          otpSendBtn.disabled = true;
        } else {
          otpSendBtn.disabled = false;
        }
      }
    }
  } catch (error) {
    if (otpLoading) otpLoading.style.display = 'none';
    if (otpMessage) {
      otpMessage.textContent = (paycellTranslations.networkError || 'Network error:') + ' ' + error.message;
      otpMessage.className = 'otp-message error';
    }
    if (otpSendBtn) otpSendBtn.disabled = false;
    console.error('Error sending OTP:', error);
  }
}

async function verifyOtp() {
  const otpCodeInput = document.getElementById('otp-code');
  const otpLoading = document.getElementById('otp-loading');
  const otpMessage = document.getElementById('otp-message');
  const otpVerifyBtn = document.getElementById('btn-verify-otp');
  const otpResendBtn = document.getElementById('btn-resend-otp');
  const otpVerifySection = document.getElementById('otp-verify-section');
  const otpSuccessMessage = document.getElementById('otp-success-message');
  
  if (!otpCodeInput || !otpCodeInput.value || otpCodeInput.value.length < 4) {
    if (otpMessage) {
      otpMessage.textContent = paycellTranslations.otpRequiredMessage || 'Please enter a valid OTP code';
      otpMessage.className = 'otp-message error';
    }
    return;
  }
  
  if (otpLoading) otpLoading.style.display = 'flex';
  if (otpMessage) {
    otpMessage.textContent = '';
    otpMessage.className = 'otp-message';
  }
  if (otpVerifyBtn) otpVerifyBtn.disabled = true;
  if (otpResendBtn) otpResendBtn.disabled = true;
  
  try {
    const transactionId = generateTransactionId();
    const transactionDateTime = generateTransactionTime();
    
    const response = await fetch(getCardsUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-TOKEN': window.prestashop.static_token
      },
      body: JSON.stringify({
        action: 'verify_otp',
        transactionId: transactionId,
        transactionDateTime: transactionDateTime,
        otpCode: otpCodeInput.value,
        referenceNumber: otpReferenceNumber,
        otpToken: otpToken
      })
    });
    
    const data = await response.json();
    
    if (otpLoading) otpLoading.style.display = 'none';
    
    if (data.success) {
      if (data.data && data.data.cards) {
        savedCards = data.data.cards;
        if (otpVerifySection) {
          otpVerifySection.style.display = 'none';
          otpVerifySection.classList.remove('active');
        }
        if (otpSuccessMessage) {
          otpSuccessMessage.style.display = 'block';
          otpSuccessMessage.classList.add('active');
        }
        setTimeout(function() {
          hideOtpSection();
          displaySavedCards();
        }, 200);
      } else {
        if (otpMessage) {
          otpMessage.textContent = paycellTranslations.otpVerifiedNoCards || 'OTP verified but no cards received';
          otpMessage.className = 'otp-message error';
        }
        if (otpVerifyBtn) otpVerifyBtn.disabled = false;
        if (otpResendBtn) otpResendBtn.disabled = false;
      }
    } else {
      if (data.data) {
        if (data.data.remainingRetryCount !== undefined) otpRemainingRetryCount = data.data.remainingRetryCount;
      } else if (data.remainingRetryCount !== undefined) {
        otpRemainingRetryCount = data.remainingRetryCount;
      }
      
      if (otpMessage) {
        let errorMsg = data.message || paycellTranslations.invalidOtp || 'Invalid OTP code. Please try again.';
        if (otpRemainingRetryCount !== null) {
          if (otpRemainingRetryCount > 0) {
            errorMsg += ' ' + (paycellTranslations.remainingAttempts || 'Remaining attempts:') + ' ' + otpRemainingRetryCount;
            otpMessage.className = 'otp-message warning';
          } else {
            errorMsg += ' ' + (paycellTranslations.maxRetryAttemptsReached || 'Maximum retry attempts reached.');
            otpMessage.className = 'otp-message error';
          }
        } else {
          otpMessage.className = 'otp-message error';
        }
        otpMessage.textContent = errorMsg;
      }
      
      if (otpRemainingRetryCount !== null && otpRemainingRetryCount <= 0) {
        if (otpResendBtn) {
          otpResendBtn.style.display = 'block';
          otpResendBtn.disabled = false;
        }
        if (otpVerifyBtn) otpVerifyBtn.disabled = true;
        if (otpCodeInput) otpCodeInput.disabled = true;
      } else {
        if (otpResendBtn) otpResendBtn.style.display = 'none';
        if (otpVerifyBtn) otpVerifyBtn.disabled = false;
        if (otpCodeInput) otpCodeInput.value = '';
      }
    }
  } catch (error) {
    if (otpLoading) otpLoading.style.display = 'none';
    if (otpMessage) {
      otpMessage.textContent = (paycellTranslations.networkError || 'Network error:') + ' ' + error.message;
      otpMessage.className = 'otp-message error';
    }
    if (otpVerifyBtn) otpVerifyBtn.disabled = false;
    if (otpResendBtn) otpResendBtn.disabled = false;
    console.error('Error verifying OTP:', error);
  }
}

document.addEventListener('DOMContentLoaded', function() {
  const otpToggleBtn = document.getElementById('btn-toggle-otp');
  const otpSendBtn = document.getElementById('btn-send-otp');
  const otpVerifyBtn = document.getElementById('btn-verify-otp');
  const otpResendBtn = document.getElementById('btn-resend-otp');
  const otpCodeInput = document.getElementById('otp-code');
  
  if (otpToggleBtn) {
    otpToggleBtn.addEventListener('click', toggleOtpSection);
  }
  
  if (otpSendBtn) {
    otpSendBtn.addEventListener('click', sendOtp);
  }
  
  if (otpVerifyBtn) {
    otpVerifyBtn.addEventListener('click', verifyOtp);
  }
  
  if (otpResendBtn) {
    otpResendBtn.addEventListener('click', function() {
      sendOtp();
    });
  }
  
  if (otpCodeInput) {
    otpCodeInput.addEventListener('keypress', function(e) {
      if (e.key === 'Enter') {
        verifyOtp();
      }
    });
    
    otpCodeInput.addEventListener('input', function(e) {
      e.target.value = e.target.value.replace(/\D/g, '');
    });
  }
});
</script>