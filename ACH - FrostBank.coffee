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
    <#-- Record Type Code (fijo '1') -->
    ${setPadding("1","left","0",1)}<#rt> 
    <#-- Priority code estándar de NACHA (fijo '01')-->
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
    <#-- Record Size (fijo '094') -->
    ${setPadding("094","left","0",3)}<#rt>
    <#-- Blocking Factor (fijo '10') -->
    ${setPadding("10","left","0",2)}<#rt>
    <#-- Format Code (fijo '1') -->
    ${setPadding("1","left","0",1)}<#rt>
    <#-- Immediate Destination Name (fijo 'FROST BANK') -->
    ${setPadding("FROST BANK","right"," ",23)}<#rt>
    <#-- Nombre Origen -->
    ${setPadding(cbank.company.legalName.custrecord_2663_legal_name,"left"," ",23)}<#rt>
    <#-- Reference Code (fijo vacio) -->
    ${setPadding(" ","left"," ",8)}<#rt>
<#-- Fin de File Header -->

<#-- Increment record counter for ACH file validation -->
<#assign recordCount = recordCount + 1>

<#-- Batch Header Record -->
    5220<#rt>
    <#-- Record Type Code (fijo '5')-->
    ${setPadding("5","left","0",1)}<#rt> 
    <#-- Service Class Code (fijo '200')-->
    ${setPadding("220" ,"left","0",3)}<#rt>
    <#-- Nombre de la Empresa -->
    ${setPadding(cbank.company.name.custrecord_2663_legal_name,"left"," ",16)}<#rt>
    <#-- Dato discrecional -->
    ${setPadding(pfa.company.discretionary.custrecord_2663_ref_note),"left"," ",20}<#rt>
    <#-- ID de la Empresa -->
    ${setPadding(cbank.companyIdentification.custrecord_2663_drt_frost_ach_company_id),"left"," ",10}<#rt>
    <#-- Standard Entry Class (SEC) Code -->
    ${setPadding("CCD","right"," ",3)}<#rt>
    <#-- Descripción de la Entrada -->
    ${setPadding(pfa.entryDescription.custrecord_2663_ref_note,"left"," ",10)}<#rt>
    <#-- Fecha descriptiva (op)-->
    
    <#-- Fecha efectiva -->
    ${setPadding(pfa.custrecord_2663_file_creation_timestamp?string["yyMMdd"] ,"left","0",6)}<#rt>  
    <#-- Settlement Date (dejar en blanco)-->
    ${setPadding(" ","left","0",3)}<#rt>
    <#-- Originator Status Code (fijo '1')-->
    ${setPadding("1","left","0",1)}<#rt>
    <#-- Originating DFI Identification -->
    ${setPadding(cbank.custrecord_drt_2663_bank_routing_num,"left"," ",8)}<#rt>
    <#assign batchNumber = 1>
    <#-- Batch Number -->
    ${setPadding(batchNumber?string, "left", "0", 7)}<#rt>
    <#assign batchNumber = batchNumber + 1>
<#-- Fin de Batch Header Record -->

<#-- Entry Detail Record-->
    <#-- Record Type Code (fijo '6') -->
    ${setPadding("6","left","0","1")}<#rt>
    <#-- Transaction Code: 2-digit code identifying the transaction type at the receiving bank. Revisar lógica!! -->
    ${setPadding("22","left","0","2")}<#rt>
    <#-- RDFI Routing -->
    ${setPadding(ebank.custpage_eft_custrecord_2663_entity_bank_no,"left","0",8)}<#rt>
    <#-- Check Digit -->
    ${setPadding(ebank.custpage_eft_custrecord_2663_entity_bank_no,"right"," ",1)}<#rt>
    <#-- Cuenta del beneficiario -->
    ${setPadding(ebank.custpage_eft_custrecord_2663_entity_acct_no,"left","0",17)}<#rt>
    <#-- Amount: Transaction amount in dollars with two decimal positions. Enter 10 zeros for prenotes.-->
    ${setPadding(formatAmount(getAmount(payment),"noDec"),"left","0",10)}<#rt>
    <#-- Individual Identification Number (op) -->
    ${setPadding(" ","left"," ",15)}<#rt>
    <#-- Individual Name -->
    ${setPadding(entity.entityid,"left"," ",22)}<#rt>
    <#-- Discretionary Data (op) -->
    ${setPadding(" ","left"," ",2)}<#rt>
    <#-- Addenda Record Indicator (fijo '0' si no hay addenda) -->
    ${setPadding("0","left","0",1)}<#rt>
    <#-- Trace ODFI -->
    ${setPadding(cbank.custrecord_drt_2663_bank_routing_num,"left"," ",8)}<#rt>
    <#-- Trace Number -->
    ${setPadding("0000001","left","0",7)}
    <#assign recordCount = recordCount + 1>
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