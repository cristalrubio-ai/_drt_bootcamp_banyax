<#-- format specific processing -->

<#-- cached values -->
<#assign newSeqId = getSequenceId(true) + 1>

<#-- template building -->
#OUTPUT START#
<#assign recordCount = 0>
<#assign totalLines = 0>
<#assign value = 0>
<#assign entryhash = 0>
<#assign batchCount = 0>

<#-- File Header Record -->
<#-- Record Type Code (fijo '1') -->
${setPadding("1","left","0",1)}<#rt> 
<#-- Priority code estándar de NACHA (fijo '01')-->
${setPadding("01" ,"left","0",2)}<#rt>
<#-- Destino Inmediato (RDFI) -->
    ${setPadding(cbank.company.bankRouting.custrecord_2663_bank_code ,"left","0",10)}<#rt>
<#-- Origen Inmediato (ODFI) -->
    ${setPadding(cbank.company.originId.custrecord_2663_acct_num ,"left","0",10)}<#rt>
<#-- Fecha de Creacion -->
    ${setPadding(pfa.custrecord_2663_file_creation_timestamp?string["yyMMdd"] ,"left","0",6)}<#rt>
<#-- Hora de Creacion -->
    ${setPadding(pfa.custrecord_2663_file_creation_timestamp?string["HHmm"] ,"left","0",4)}<#rt>
<#-- File ID Modifier (revisar lógica) -->
${setPadding(newSeqId,"left","0",1)}<#rt>
<#-- Record Size (fijo '094') -->
${setPadding("094","left","0",3)}<#rt>
<#-- Blocking Factor (fijo '10') -->
${setPadding("10","left","0",2)}<#rt>
<#-- Format Code (fijo '1') -->
${setPadding("1","left","0",1)}<#rt>
<#-- Immediate Destination Name (fijo 'FROST BANK') -->
${setPadding("FROST BANK","left"," ",23)}<#rt>
<#-- Nombre Origen -->
    ${setPadding(cbank.company.legalName.custrecord_2663_legal_name,"left"," ",23)}<#rt>
<#-- Reference Code (fijo vacio) -->
${setPadding(" ","left"," ",8)}<#rt>
<#assign recordCount = recordCount + 1>
<#-- Fin de File Header -->

<#-- Batch Header Record -->
<#-- Record Type Code (fijo '5')-->
${setPadding("5","left","0",1)}<#rt> 
<#-- Service Class Code (fijo '220')-->
${setPadding("220" ,"left","0",3)}<#rt>
<#-- Nombre de la Empresa -->
    ${setPadding(cbank.company.name.custrecord_2663_legal_name,"left"," ",16)}<#rt>
<#-- Dato discrecional -->
    ${setPadding(pfa.company.discretionary.custrecord_2663_ref_note,"left"," ",20)}<#rt>
<#-- ID de la Empresa -->
    ${setPadding(cbank.companyIdentification.custrecord_2663_acct_num, "left", " ", 10)}<#rt>
<#-- Standard Entry Class (SEC) Code -->
${setPadding("CCD","left"," ",3)}<#rt>
<#-- Descripción de la Entrada -->
    ${setPadding(pfa.entryDescription.custrecord_2663_ref_note,"left"," ",10)}<#rt>
<#-- Fecha descriptiva (op)-->
${setPadding(pfa.descriptiveDate?string["yyMMdd"] ,"left","0",6)}<#rt>
<#-- Fecha efectiva -->
    ${setPadding(pfa.custrecord_2663_file_creation_timestamp?string["yyMMdd"] ,"left","0",6)}<#rt>  
<#-- Settlement Date (dejar en blanco)-->
${setPadding(" ","left","0",3)}<#rt>
<#-- Originator Status Code (fijo '1')-->
${setPadding("1","left","0",1)}<#rt>
<#-- Originating DFI Identification -->
    ${setPadding(cbank.custrecord_2663_bank_code,"left","0",8)}<#rt>
<#-- Batch Number (fijo '0000001') -->
${setPadding("1","left","0",7)}<#rt>
<#assign recordCount = recordCount + 1>
<#-- Fin de Batch Header Record -->

<#list payments as payment>
<#assign ebank = ebanks[payment_index]>
<#assign entity = entities[payment_index]>

### Asign para amount ###
<#assign monto = getAmount(payment)?number>

### Logica para amount ###
<#if monto == 0>
  <#assign montoTxt = "0000000000">
<#else>
  <#assign montoTxt = monto?string["0.00"]?left_pad(10, '0')>
</#if>

<#-- Entry Detail Record-->
<#-- Record Type Code (fijo '6') -->
${setPadding("6","left","0","1")}<#rt>
<#-- Transaction Code (fijo '22') -->
${setPadding("22","left","0","2")}<#rt>
<#-- RDFI Routing -->
    ${setPadding(ebank.custrecord_2663_entity_bank_no,"left","0",8)}<#rt>
<#-- Check Digit -->
    ${setPadding(ebank.custrecord_2663_entity_bank_no,"left","0",1)}<#rt>
<#-- Cuenta del beneficiario -->
    ${setPadding(ebank.custrecord_2663_entity_acct_no,"left","0",17)}<#rt>
<#-- Amount -->
${montoTxt}<#rt>
<#-- Individual Identification Number (entity) -->
    ${setPadding(entity.entityid,"left"," ",15)}<#rt>
<#-- Individual Name -->
${setPadding(entity.companyname,"left"," ",22)}<#rt>
<#-- Discretionary Data (vacio) -->
${setPadding(" ","left"," ",2)}<#rt>
<#-- Addenda Record Indicator (fijo '0' si no hay addenda) -->
${setPadding("0","left","0",1)}<#rt>
<#-- Trace ODFI -->
    ${setPadding(cbank.custrecord_2663_bank_code,"left","0",8)}<#rt>
<#-- Trace Number (revisar lógica) -->
${"11400009"}${setPadding(entrySequence?string,"left","0",7)}<#rt>
<#assign recordCount = recordCount + 1>
<#-- Fin de Entry Details -->

<#-- Cálculos para Batch Control y File Control -->
<#assign totalLines = totalLines + 1>
<#assign value = value + getAmount(payment)>
<#assign entryhash = 0>
<#assign routing8 = entry.routingNumber?substring(0, 8)?number>
<#assign entryhash = entryhash + routing8>
<#assign entryhashStr = entryhash?string>
<#if entryhashStr?length > 10>
<#assign entryhashStr = entryhashStr?substring(entryhashStr?length - 10)>
</#if>

</#list>

<#-- Batch Control -->
<#-- Record Type Code -->
${setPadding("8","left","0",1)}<#rt>
<#-- Service Class Code (fijo '220') -->
${setPadding("220","left","0",3)}<#rt>
<#-- Entry/Addenda Count -->
${setPadding(totalLines,"left","0",6)}<#rt>
<#-- Entry Hash (revisar lógica)-->
${entryhashStr?left_pad(10, '0')}<#rt>
<#-- Total Debit Amount -->
${setPadding("0","left","0",12)}<#rt>
<#-- Total Credit Amount -->
    ${setPadding(formatAmount(value,"noDec"),"left","0",12)}<#rt>
<#-- Company identification (debe coicidir con Batch Header) -->
    ${setPadding(cbank.companyIdentification.custrecord_2663_legal_name,"left"," ",10)}<#rt>
<#-- Message Authentication Code (fijo vacio) -->
${setPadding(" ","left"," ",19)}<#rt>
<#-- Filler (fijo vacio) -->
${setPadding(" ","left"," ",6)}<#rt>
<#-- ODFI Identification -->
    ${setPadding(cbank.custrecord_2663_bank_code,"left","0",8)}<#rt>
<#-- Batch Number (Fijo '0000001') -->
${setPadding("1","left","0",7)}<#rt>
<#assign recordCount = recordCount + 1>
<#-- Fin de Batch Control Record -->

<#-- File Control Record -->
<#assign totalSuma = 0>
<#list routing8 as numero>
<#assign totalSuma = totalSuma + numero>
### Logica para el entryhash ###

<#assign totalCount = entries?size> ### Este calcula la secuancia de entries, entries?size es un built-in que devuelve la cantiadad de elementos en una secuencia. ###
### Logica para  entryhash ###

<#-- Tipo de registro (Fijo '9') -->
${setPadding("9","left","0",1)}<#rt>
<#-- Batch Count (fijo '0000001')-->
${setPadding("1","left","0",6)}<#rt>
<#-- Block Count with calcBlocks() -->
${setPadding(calcBlocks(recordCount),"left","0",6)}<#rt>
<#-- Entry/Addenda Count with count(entries) -->
${totalCount?string?left_pad(8, '0')}<#rt>
<#-- Entry Hash sum(routing8) (Revisar lógica) -->
${setPadding(totalSuma, "left", "0", 10)}<#rt>
<#-- Total Debit Amount -->
${setPadding("0","left","0",12)}<#rt>
<#-- Total Credit Amount -->
${setPadding(formatAmount(value,"noDec"),"left","0",12)}<#rt>
<#-- Filler (fijo vacio) -->
${setPadding(" ","left"," ",39)}<#rt>
<#assign recordCount = recordCount + 1>
<#-- Padding to complete blocks of 10 records -->
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
#RETURN START#
sequenceId:${newSeqId}
#RETURN END#