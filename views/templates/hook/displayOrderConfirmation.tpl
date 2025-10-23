{*
* Paycell Payment Gateway Order Confirmation Template
* 
* @author    Paycell <info@paycell.com.tr>
* @copyright 2025 Paycell
*}

<div class="paycell-order-confirmation">
    <h3>{l s='Payment Information' d='Modules.Paycellpaymentgateway.Shop'}</h3>
    <p>{l s='Your order has been paid successfully through Paycell payment gateway.' d='Modules.Paycellpaymentgateway.Shop'}</p>
    <p><strong>{l s='Order Reference:' d='Modules.Paycellpaymentgateway.Shop'}</strong> {$reference}</p>
    <p><strong>{l s='Total Paid:' d='Modules.Paycellpaymentgateway.Shop'}</strong> {$total}</p>
    <p>{l s='If you have any questions, please' d='Modules.Paycellpaymentgateway.Shop'} <a href="{$contact_url}">{l s='contact us' d='Modules.Paycellpaymentgateway.Shop'}</a>.</p>
</div>
