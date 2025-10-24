<#-- format specific processing -->

<#function getBlockNumber>
<#assign processDate = pfa.custrecord_2663_file_creation_timestamp?date?long>
<#return processDate>
</#function>

<#function getTipoCuenta cuenta>
<#assign value = cuenta>
<#assign result = value>
<#if value?starts_with("Tarjeta") == true >
<#assign result = "03">
<#else>
<#assign result = "40">
</#if>
<#return result>
</#function>

<#-- template building -->
#OUTPUT START#
<#assign value = 0>
<#list payments as payment>
<#assign ebank = ebanks[payment_index]>
<#assign entity = entities[payment_index]>
<#assign totalLines = totalLines + 1 >
<#assign value = value + getAmount(payment)>

<#-- Inicio building banregio--> 
<#-- Tipo -->
${setPadding(payment.custbody_dr_banyax_type_transfer,"left"," ",1)},<#rt>
<#-- cuenta destino -->
${setPadding(payment.custpage_eft_custrecord_2663_entity_acct_no,"left","0",20)},<#rt>
<#-- importe -->
${setPadding(formatAmount(getAmount(payment),"dec"),"left","0",16)},<#rt>
<#-- IVA -->
${setPadding(" ","left"," ",16)},<#rt>
<#-- Descripcion -->
${setPadding(payment.memo,"left"," ",40)},<#rt>
<#-- cuenta origen -->
${setPadding(cbank.custpage_eft_custrecord_2663_acct_num,"left","0",20)},<#rt>
<#-- Ref_Numerica -->
${setPadding(payment.custbody_dr_banyax_ref_number,"left","0",15)}

<#-- Fin del building -->
</#if>
</#list>
#OUTPUT END#