<#-- format specific processing -->
#OUTPUT START#
<#assign recordCount = 0>
<#assign totalLines = 0>
<#assign value = 0>
<#assign entryhash = 0>

<#function getNextFileId>
  <#-- The first (or only) file should start with "A" or "1". Subsequent files should be labeled in sequential order: "B", "C", etc., or "2", "3", etc. -->
  <#assign currentDate = .now?string["yyyyMMdd"]>
  <#assign lastId = getLastFileIdForDate(currentDate)!"">
  
  <#if !lastId?has_content>
    <#return "A">
  <#else>
    <#return getNextSequentialId(lastId)>
  </#if>
</#function>

<#-- File Header Record -->
    101<#rt>
    <#-- Record Type Code (No estoy segura si es así :v) -->
    ${setPadding(CustomRecordType.custrecord_2663_drt_frost_ach_file_type.custrecord_2663_drt_frost_ach_file_type_code ,"left","0",1)}<#rt>
    <#-- Priority code estándar de NACHA-->
    ${setPadding("01" ,"left","0",2)}<#rt>
    <#-- Destino Inmediato (RDFI) -->
    ${setPadding(cbank.company.bankRouting.custrecord_drt_2663_bank_routing_num ,"left","0",10)}<#rt>
    <#-- Origen Inmediato (ODFI) -->
    ${setPadding(cbank.company.originId.custrecord_2663_drt_frost_ach_company_id ,"left","0",10)}<#rt>
    <#-- Fecha de Creacion -->
    ${setPadding(pfa.custrecord_2663_file_creation_timestamp?string["yyMMdd"] ,"left","0",6)}<#rt>  
    <#-- Hora de Creacion -->
    ${setPadding(pfa.custrecord_2663_file_creation_timestamp?string["HHmm"] ,"left","0",4)}<#rt>
    <#-- No estoy seguro que esto sea asi -->
    <#-- File ID Modifier (crear lógica) -->
    ${setPadding(getNextFileId(),"left"," ",1)}<#rt>
    <#-- Nombre Origen -->
    ${setPadding(cbank.company.legalName.custrecord_2663_legal_name,"left"," ",23)}<#rt>
<#-- Fin de File Header -->

101 111000015${setLength(cbank.custrecord_2663_ach_id,10)}<#rt>
A094101<#rt>
${setPadding("FROST BANK","right"," ",23)}<#rt>
${setPadding("FIRST CASH HOLDINGS","right"," ",23)}<#rt>
${setPadding(" ","left"," ",8)}
<#assign recordCount = recordCount + 1>


<#-- Batch Header Record -->
    5220<#rt>

    <#-- Nombre de la Empresa -->
    ${setPadding(cbank.company.name.custrecord_2663_legal_name,"left"," ",16)}<#rt>

    <#-- Dato discrecional -->
    ${setPadding(pfa.company.discretionary.custrecord_2663_ref_note),"left"," ",20}<#rt>

    <#-- ID de la Empresa -->
    ${setPadding(cbank.companyIdentification.custrecord_2663_drt_frost_ach_company_id),"left"," ",10}<#rt>

    <#-- Descripción de la Entrada -->
    ${setPadding(pfa.entryDescription.custrecord_2663_ref_note,"left"," ",10)}<#rt>

    <#-- Fecha efectiva -->
    ${setPadding(pfa.custrecord_2663_file_creation_timestamp?string["yyMMdd"] ,"left","0",6)}<#rt>  

    <#-- ODFI Identification -->
    ${setPadding(cbank.custrecord_drt_2663_bank_routing_num),"left"," ",10}<#rt>  
    <#-- No estoy seguro que esto sea asi -->
<#-- Fin de Batch Header Record -->

<#-- Entry Details -->
    <#-- RDFI Routing -->
    ${setPadding(ebank.custpage_eft_custrecord_2663_entity_bank_no,"left","0",8)}<#rt>

    <#-- Check Digit -->
    ${setPadding(ebank.custpage_eft_custrecord_2663_entity_bank_no,"right"," ",1)}<#rt>

    <#-- Cuenta del beneficiario -->
    ${setPadding(ebank.custpage_eft_custrecord_2663_entity_acct_no,"left","0",17)}<#rt>

    <#-- Trace ODFI -->
    ${setPadding(cbank.custrecord_drt_2663_bank_routing_num,"left"," ",8)}<#rt>
<#-- Fin de Entry Details -->

<#-- Batch Control -->
    <#-- Company identification -->
    ${setPadding(cbank.companyIdentification.custrecord_2663_legal_name,"left"," ",10)}<#rt>

    <#-- ODFI Identification -->
    ${setPadding(cbank.custrecord_drt_2663_bank_routing_num,"left"," ",8)}<#rt>




    ${setPadding("FIRST CASH HOLDINGS","right"," ",16)}<#rt>
    ${setPadding(" ","left"," ",20)}${setLength(cbank.custrecord_2663_ach_id,10)}CCD<#rt>
    ${setPadding("CASH CONC","right"," ",10)}<#rt>
    ${setPadding(pfa.custrecord_2663_process_date?string["yyMMdd"] ,"left","0",6)}<#rt>
    ${setPadding(pfa.custrecord_2663_process_date?string["yyMMdd"] ,"left","0",6)}<#rt>
    ${setPadding(" ","left"," ",3)}<#rt>
    1111000150000001
    <#assign recordCount = recordCount + 1>
    <#-- Details Record -->
    <#list payments as payment>
    <#assign ebank = ebanks[payment_index]>
    <#assign totalLines = totalLines + 1 >
    <#assign entity = entities[payment_index]>
    <#assign value = value + getAmount(payment)>
    <#assign entryhash = entryhash + (setPadding(ebank.custrecord_2663_entity_bic,"left","0",9)?substring(0,8))?number>
    622<#rt>
    ${setPadding(ebank.custrecord_2663_entity_bic,"left","0",9)}<#rt>
    ${setPadding(ebank.custrecord_2663_entity_bban,"right"," ",17)}<#rt>
    ${setPadding(formatAmount(getAmount(payment),"noDec"),"left","0",10)}<#rt>
    ${setLength(entity.entityid,15)}<#rt>
    ${setLength(entity.companyname,22)}<#rt>
    ${setPadding(" ","left"," ",2)}<#rt>
    009100001${setPadding((payment_index?number + 1),"left","0",7)}
    <#assign recordCount = recordCount + 1>
    </#list>
<#-- Fin de Batch Control Record -->
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
<#-- Fin de File Control Record -->
#OUTPUT END#