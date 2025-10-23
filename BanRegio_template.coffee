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
<<<<<<< HEAD:BanRegio_template.coffee
<#assign entryhash = entryhash + (setPadding(ebank.custrecord_2663_entity_bic,"left","0",9)?substring(0,8))?number>
622<#rt>

<#-- Inicio building banregio--> 
<#-- Tipo -->
${setPadding(payment.custbody_dr_banyax_type_transfer,"left"," ",1)}<#rt>

<#-- cuenta destino -->
${setPadding(payment.custpage_eft_custrecord_2663_entity_acct_no,"left","0",20)}<#rt>

<#-- cuenta destino -->
${setPadding(formatAmount(getAmount(payment),"noDec"),"left","0",20)}<#rt>
<#-- payment pendiente -->

<#-- cuenta origen -->
${setPadding(cbank.custpage_eft_custrecord_2663_acct_num,"left","0",20)}<#rt>

<#-- Ref_Numerica -->
${setPadding(payment.custbody_dr_banyax_ref_number,"left","0",15)}<#rt>

<#-- Fin del building -->

${setLength(entity.entityid,15)}<#rt>
${setLength(entity.companyname,22)}<#rt>
${setPadding(" ","left"," ",2)}<#rt>
009100001${setPadding((payment_index?number + 1),"left","0",7)}
<#assign recordCount = recordCount + 1>
</#list>
<#-- Batch Control Record -->
8220<#rt>
${setPadding(totalLines,"left","0",6)}<#rt>
${setPadding(entryhash,"left","0",10)}<#rt>
${setPadding("0","left","0",12)}<#rt>
${setPadding(formatAmount(value,"noDec"),"left","0",12)}${setLength(cbank.custrecord_2663_ach_id,10)}<#rt>
${setPadding(" ","left"," ",25)}<#rt>
091000010000001${setPadding((payment_index?number + 1),"left","0",7)}
<#assign recordCount = recordCount + 1>
<#-- File Control Record -->
9000001000001<#rt>
${setPadding(totalLines,"left","0",8)}<#rt>
${setPadding(entryhash,"left","0",10)}<#rt>
${setPadding("0","left","0",12)}<#rt>
${setPadding(formatAmount(value,"noDec"),"left","0",12)}<#rt>
${setPadding(" ","left"," ",39)}<#rt>
<#assign recordCount = recordCount + 1>
<#if (recordCount % 10 > 0)>
<#assign padBlocksString = "\n">
<#assign numBlocks = 10 - (recordCount % 10) >
<#assign padding = "9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999">
<#list 1..numBlocks as i>
<#assign padBlocksString = padBlocksString + padding + "\n">
</#list>
=======
${setPadding(cbank.custrecord_drt_numero_de_cuenta,"left","0",18)}<#rt>
${setPadding(ebank.custrecord_2663_entity_acct_no,"left"," ",35)}<#rt>
${setPadding(formatAmount(getAmount(payment),"dec"),"left","0",16)}<#rt>
${setPadding(payment.currency,"left"," ",3)}<#rt>


${setPadding(ebank.custrecord_drt_clabe_interbancaria_bbva,"left","0",18)}<#rt>
${setPadding(cbank.custpage_eft_custrecord_2663_acct_num,"left","0",18)}<#rt>
MXP<#rt>
${setPadding(formatAmount(getAmount(payment),"dec"),"left","0",16)}<#rt>
${setPadding(entity.entityid,"left"," ",30)}<#rt>
${setPadding(ebank.custrecord_drt_tipo_cuenta_bbva,"left","0",2)}<#rt>
${setPadding(ebank.custrecord_drt_clave_banco_banxico_bbva,"left","0",3)}<#rt>
${setPadding(payment.custbody_drt_reference_payment,"left"," ",30)}<#rt>
${setPadding(payment.custbody_drt_reference_number,"left","0",7)}<#rt>
H
>>>>>>> dec12ec18580687c5fca9d05ced1f2af7060fe18:BanRegio_template.txt
</#if>
<#if ebank.custrecord_drt_clave_bbva_mixto == "PTC">
PTC<#rt>
${setPadding(ebank.custrecord_drt_clabe_interbancaria_bbva,"left","0",18)}<#rt>
${setPadding(cbank.custpage_eft_custrecord_2663_acct_num,"left","0",18)}<#rt>
MXP<#rt>
${setPadding(formatAmount(getAmount(payment),"dec"),"left","0",16)}<#rt>
${setPadding(payment.custbody_drt_reference_payment,"left"," ",30)}
</#if>
<#if ebank.custrecord_drt_clave_bbva_mixto == "CIL">
CIL<#rt>
${setPadding(ebank.custrecord_drt_concepto_cie_bbva,"left"," ",30)}<#rt>
${setPadding(ebank.custrecord_drt_convenio_cie_bbva,"left","0",7)}<#rt>
${setPadding(cbank.custpage_eft_custrecord_2663_acct_num,"left","0",18)}<#rt>
${setPadding(formatAmount(getAmount(payment),"dec"),"left","0",16)}<#rt>
${setPadding(payment.custbody_drt_reference_payment,"left"," ",30)}<#rt>
${setPadding(ebank.custrecord_drt_referencia_cie_bbva,"left"," ",20)}
</#if>
<#if ebank.custrecord_drt_clave_bbva_mixto == "OPI">
OPI<#rt>
${setPadding(cbank.custpage_eft_custrecord_2663_acct_num,"left","0",18)}<#rt>
${setPadding(ebank.custrecord_drt_clabe_interbancaria_bbva,"left","0",35)}<#rt>
${setPadding(formatAmount(getAmount(payment),"dec"),"left","0",16)}<#rt>
${setPadding(payment.currency,"left"," ",3)}<#rt>
${setPadding(payment.custbody_drt_reference_payment,"left"," ",50)}<#rt>
${setPadding(ebank.custrecord_drt_aba_bic_bbva,"left"," ",15)}<#rt>
${setPadding(ebank.custrecord_drt_banco_beneficiario_bbva,"left"," ",30)}<#rt>
${setPadding(ebank.custrecord_drt_pais_beneficiario_bbva,"left"," ",30)}<#rt>
${setPadding(ebank.custrecord_drt_direccion_beneficiario_bb,"left"," ",40)}<#rt>
${setPadding(entity.entityid,"left"," ",30)}<#rt>
${setPadding(entity.billcountry,"left"," ",30)}<#rt>
${setPadding(payment.custbody_drt_direccion_layout,"left"," ",40)}<#rt>
${setPadding(entity.phone?replace('+', ''), "left", " ", 12)}
</#if>
</#list>
#OUTPUT END#
