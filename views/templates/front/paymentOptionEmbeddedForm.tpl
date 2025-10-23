{**
 * Paycell Payment Gateway Embedded Form Template
 * 
 * @author    Paycell <info@paycell.com.tr>
 * @copyright 2025 Paycell
 *}

<form id="js-paycell-payment-form">
  <input type="hidden" name="option" value="embedded">
  <input type="hidden" name="card_token" id="card_token" value="">

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

  <!-- Installment Options -->
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
</style>

<script>
// JavaScript translations
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
  installments: '{$js_translations.installments|escape:'javascript'}'
};


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
    showInstallmentOptionsDisabled(); // Show disabled installment options by default
    $placeOrderButton.addEventListener('click', handleClick);
  } else {
    radioButtons.forEach(function (input) {
      input.addEventListener("change", function() {
        if(input.dataset.moduleName === 'paycell_payment_gateway' && input.checked && $paymentForm) {
          $paymentForm.addEventListener("submit", handleSubmit);
          initialize();
          showInstallmentOptionsDisabled(); // Show disabled installment options by default
          $placeOrderButton.addEventListener('click', handleClick);
        } else {
          $placeOrderButton.removeEventListener('click', handleClick);
        }
      });
      if(input.dataset.moduleName === 'paycell_payment_gateway' && input.checked && $paymentForm) {
        showInstallmentOptionsDisabled(); // Show disabled installment options by default
        $placeOrderButton.addEventListener('click', handleClick);
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
    const timestamp = Date.now().toString(); // 13 digits
    const random = Math.floor(Math.random() * 1e7).toString().padStart(7, '0'); // 7 digits
    const transactionId = timestamp + random; // 13 + 7 = 20 digits
    return transactionId;
}

function generateTransactionNumber() {
    const numberTimestamp = Date.now().toString();
    const numberRandom = Math.floor(Math.random() * 1e7).toString().padStart(7, '0');
    const transactionNumber = numberTimestamp + numberRandom;
    return transactionNumber;
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
  
  // Trigger form submission
  $paymentForm.dispatchEvent(new Event('submit'));
}

function initialize() {
  // Format card number with spaces and BIN checking
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
      
      // Clear previous timeout
      clearTimeout(binCheckTimeout);
      
      // Check BIN if we have at least 6 digits
      if (value.length >= 6) {
        binCheckTimeout = setTimeout(() => {
          checkBinInfo(value.substring(0, 6));
        }, 500); // Wait 500ms after user stops typing
      } else {
        // Show installment options as disabled
        showInstallmentOptionsDisabled();
      }
    });
  }

  // Format expiry date
  const cardExpiry = document.getElementById('cardExpiry');
  if (cardExpiry) {
    cardExpiry.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\D/g, '');
      if (value.length >= 2) {
        value = value.substring(0, 2) + '/' + value.substring(2, 4);
      }
      e.target.value = value;
    });
    
    // Add validation on blur
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

  // Only allow numbers for CVV
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

  // Validate form
  if (!validateForm()) {
    handleError(paycellTranslations.fillRequiredFields);
    return;
  }

  // Get card data
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
    // Tokenize card using external API
    const token = await tokenizeCard(cardData, transactionId, transactionTime);
    
    if (token) {
      // Set token and redirect to payment processing
      document.getElementById('card_token').value = token;
      
      // Redirect to payment processing
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
      
      form.appendChild(tokenInput);
      form.appendChild(optionInput);
      form.appendChild(transactionIdInput);
      form.appendChild(transactionNumberInput);
      form.appendChild(transactionTimeInput);
      form.appendChild(installmentCountInput);
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
  
  // Validate expiry date is not in the past
  const [month, year] = expiry.split('/');
  const currentDate = new Date();
  const currentYear = currentDate.getFullYear() % 100; // Get last 2 digits
  const currentMonth = currentDate.getMonth() + 1; // getMonth() returns 0-11
  
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
    // First, get the hash from our server
    const hashResponse = await fetch('{$action}', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
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

    // Now make the tokenization request with the hash
    const response = await fetch('https://omccstb.turkcell.com.tr/paymentmanagement/rest/getCardTokenSecure', {
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
  
  // Show error message
  const messageContainer = document.querySelector('#error-message');
  if (messageContainer) {
    messageContainer.textContent = error;
  } else {
    // Create error message element
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

// BIN Checking Functions
async function checkBinInfo(binNumber) {
  try {
    const transactionId = generateTransactionId();
    const transactionDateTime = generateTransactionTime();
    
    const response = await fetch('{$link->getModuleLink("paycell_payment_gateway", "bininfo", [], true)}', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
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
    // Clear existing options
    installmentSelect.innerHTML = '';
    
    // Add installment options from 1 to 12
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
    
    // Enable the select
    installmentSelect.disabled = false;
    installmentSelect.style.opacity = '1';
    installmentGroup.style.display = 'block';
  }
}

function showInstallmentOptionsDisabled() {
  const installmentGroup = document.getElementById('installment-group');
  const installmentSelect = document.getElementById('installmentCount');
  
  if (installmentGroup && installmentSelect) {
    // Clear existing options
    installmentSelect.innerHTML = '';
    
    // Add only single payment option
    const option = document.createElement('option');
    option.value = '1';
    option.textContent = paycellTranslations.singlePayment;
    option.selected = true;
    installmentSelect.appendChild(option);
    
    // Disable the select
    installmentSelect.disabled = true;
    installmentSelect.style.opacity = '0.6';
    installmentGroup.style.display = 'block';
  }
}

function hideInstallmentOptions() {
  const installmentGroup = document.getElementById('installment-group');
  if (installmentGroup) {
    installmentGroup.style.display = 'none';
  }
}
</script>