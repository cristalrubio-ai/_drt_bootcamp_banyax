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
<#assign entryhash = entryhash + (setPadding(ebank.custrecord_2663_entity_bic,"left","0",9)?substring(0,8))?number>
622<#rt>

<#-- Inicio building banregio--> 
<#-- Tipo -->
${setPadding(payment.custbody_dr_banyax_type_transfer,"left"," ",1)}<#rt>

<#-- cuenta destino -->
${setPadding(payment.custpage_eft_custrecord_2663_entity_acct_no,"left","0",20)}<#rt>

<#-- importe -->
${setPadding(formatAmount(getAmount(payment),"dec"),"left","0",16)}<#rt>

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
</#if>
</#list>
#OUTPUT END#
