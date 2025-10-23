<#-- format specific processing -->
#OUTPUT START#
<#assign recordCount = 0>
<#assign totalLines = 0>
<#assign value = 0>
<#assign entryhash = 0>

<#-- File Header Record -->
<#-- Destino Inmediato (RDFI) -->
${setPadding(company.bankRouting.custrecord_drt_2663_bank_routing_num ,"left","0",6)}<#rt>

<#-- Origen Inmediato (ODFI) -->
${setPadding(company.originId.custrecord_2663_drt_frost_ach_company_id ,"left","0",6)}<#rt>



101 091000019${setLength(cbank.custrecord_2663_ach_id,10)}<#rt>
${setPadding(pfa.custrecord_2663_file_creation_timestamp?string["yyMMdd"] ,"left","0",6)}<#rt>
${setPadding(pfa.custrecord_2663_file_creation_timestamp?string["HHmm"] ,"left","0",4)}<#rt>
A094101<#rt>
${setPadding("WELLS FARGO","right"," ",23)}<#rt>
${setPadding("FIRST CASH HOLDINGS","right"," ",23)}<#rt>
${setPadding(" ","left"," ",8)}
<#assign recordCount = recordCount + 1>
<#-- Batch Header Record -->
5220<#rt>
${setPadding("FIRST CASH HOLDINGS","right"," ",16)}<#rt>
${setPadding(" ","left"," ",20)}${setLength(cbank.custrecord_2663_ach_id,10)}CCD<#rt>
${setPadding("CASH CONC","right"," ",10)}<#rt>
${setPadding(pfa.custrecord_2663_process_date?string["yyMMdd"] ,"left","0",6)}<#rt>
${setPadding(pfa.custrecord_2663_process_date?string["yyMMdd"] ,"left","0",6)}<#rt>
${setPadding(" ","left"," ",3)}<#rt>
1091000010000001
<#assign recordCount = recordCount + 1>
<#-- Details Record -->
<#list payments as payment>
<#assign ebank = ebanks[payment_index]>
<#assign totalLines = totalLines + 1 >
<#assign entity = entities[payment_index]>
<#assign value = value + getAmount(payment)>
<#assign entryhash = entryhash + (setPadding(ebank.custrecord_2663_entity_bic,"left","0",9)?substring(0,8))?number>
622<#rt>

<#-- Inicio building banregio--> 
<#-- Tipo -->
${setPadding(payment.custbody_dr_banyax_type_transfer,"left"," ",1)}<#rt>

<#-- cuenta destino -->
${setPadding(payment.custpage_eft_custrecord_2663_entity_acct_no,"left","0",20)}<#rt>

<#-- cuenta destino -->
${setPadding(formatAmount(getAmount(payment),"noDec"),"left","0",10)}<#rt>
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
</#if>
${padBlocksString}<#rt>
#OUTPUT END#