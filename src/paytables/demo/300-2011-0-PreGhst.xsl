<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />
	<xsl:variable name="bingoColumns">
		<xsl:value-of select="//GHSTBingoMappings/BingoColumns/@names" />
	</xsl:variable>
	<xsl:variable name="patternNamesString">
		<xsl:value-of select="//GHSTBingoMappings/PrizeNames/@prizes" />
	</xsl:variable>
	<xsl:variable name="patternDefString">
		<xsl:value-of select="//GHSTBingoMappings/PatternDefinitions/@patterns" />
	</xsl:variable>
	<xsl:variable name="pricePointsString">
		<xsl:value-of select="//GHSTBingoMappings/PricePoints/@pricePoints" />
	</xsl:variable>
	<xsl:variable name="prizeTableString">
		<xsl:value-of select="//GHSTBingoMappings/PrizeTables/@prizeValues" />
	</xsl:variable>

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson retrievePrizeTable retrievePatternWins">
				<lxslt:script lang="javascript">
					<![CDATA[
					var debugFeed = [];
					var debugFlag = false;
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param bingoColumns String of Bingo Symbols.
					function formatJson(jsonContext, translations, patternDef, convertedPrizeValues, bingoColumns, convertedPatternWins, patternNames)
					{
						var scenario = getScenario(jsonContext);
						var bingoSymbols = bingoColumns.split(",");
						var drawnNumbers = (scenario.split("|")[0]).split(",");
						var bingoCardData = (scenario.split("|")[1]).split(",");
						var prizePatterns = patternDef.split("|");
						var prizeValues = (convertedPrizeValues.substring(1)).split('|');
						var patternWins = (convertedPatternWins.substring(1)).split('|');
						var bingoPatterns = patternNames.split(",");
						
						
						registerDebugText("Pattern Wins Count: " + patternWins.length);
						for(var i = 0; i < patternWins.length; ++i)
						{
							registerDebugText("Win[" + i + "]: " + patternWins[i]);
						
						}
						
						var r = [];
						
						// Output Bingo Patterns
						/////////////////////////////
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed;display:inline-block">');
						
							r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable" style="table-layout:fixed;display:inline-block">');
							r.push('<tr><td class="tablehead" colspan="' + bingoSymbols.length + '">');
							r.push(getTranslationByName("prizePatterns", translations));
							r.push('</td>');
							r.push('</tr>');
							
							for(var row = 0; row < bingoSymbols.length; ++row)
							{
								r.push('<tr class="tablebody" height="20">');
							}
							
							r.push('<tr><td class="tablehead" colspan="' + bingoSymbols.length + '">');
							r.push(getTranslationByName("winsPerPattern", translations));
							r.push('</td>');
							r.push('</tr>');
							
							r.push('</table>');
						
							for(var pattern = 0; pattern < prizePatterns.length; ++pattern)
							{
								r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable" style="table-layout:fixed;display:inline-block">');
								
								r.push('<tr>');
								r.push('<td class="tablehead" colspan="' + bingoSymbols.length + '">');
								r.push(getTranslationByName(bingoPatterns[pattern], translations));
								r.push('</td>');
								r.push('</tr>');
								
								for(var row = 0; row < bingoSymbols.length; ++row)
								{
									var rowSpots = prizePatterns[pattern].split(",")[row];
									r.push('<tr height="20">');
									for(var spot = 0; spot < bingoSymbols.length; ++spot)
									{
										r.push('<td class="tablebody" width="20">');
										r.push(rowSpots[spot]);
										r.push('</td>');
									}
									r.push('</tr>');
								}
								
								r.push('<tr>');
								r.push('<td class="tablehead bold" colspan="' + bingoSymbols.length + '">');
								r.push(patternWins[pattern]);
								r.push('</td>');
								r.push('</tr>');
								
								r.push('</table>');
							}
						
						r.push('</table>');

						// Output Bingo Card Data
						////////////////////////////
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
						r.push('<tr><td class="tablehead" colspan="' + bingoSymbols.length + '">');
						r.push(getTranslationByName("bingoCardNumbers", translations));
						r.push('</td>');
						r.push('</tr>');
						
						r.push('<tr>');
						for(var i = 0; i < bingoSymbols.length; ++i)
						{
							r.push('<td class="tablehead">');
							r.push(bingoSymbols[i]);
							r.push('</td>');
						}
						r.push('</tr>');
						
						for(var x = 0; x < bingoSymbols.length; ++x)
						{	
							r.push('<tr>');
							for(var y = 0; y < bingoSymbols.length; ++y)
							{
								var data = bingoCardData[y * bingoSymbols.length + x];
								if(data == "FREE")
								{
									r.push('<td class="tablebody bold">');
									r.push(getTranslationByName("freeSpace", translations));
								}
								else if(checkMatch(drawnNumbers, data))
								{
									r.push('<td class="tablebody bold">');
									r.push(getTranslationByName("youMatched", translations) + ": " + data);
								}
								else
								{
									r.push('<td class="tablebody">');
									r.push(data);
								}
								r.push('</td>');								
							}
							r.push('</tr>');
						}
						r.push('</table>');
						
						// Output Drawn Numbers
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
						r.push('<tr><td class="tablehead" width="100%">');
						r.push(getTranslationByName("drawnNumbers", translations));
						r.push('</td>');
						r.push('</tr>');
						
						for(var num = 0; num < drawnNumbers.length; ++num)
						{
							r.push('<tr>');	
							r.push('<td class="tablebody" width="100%">');
							r.push(drawnNumbers[num]);
							r.push('</td>');
							r.push('</tr>');	
						}				
							
						r.push('</table>');
						
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
							{
								r.push('<tr>');
								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
								r.push('</td>');
								r.push('</tr>');
							}
							r.push('</table>');
						}

						return r.join('');
					}
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: List of winning numbers and the number to check
					// Output: true is number is contained within winning numbers or false if not
					function checkMatch(winningNums, boardNum)
					{
						for(var i = 0; i < winningNums.length; ++i)
						{
							if(winningNums[i] == boardNum)
							{
								return true;
							}
						}
						
						return false;
					}
					
					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}
					
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeTables, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeTableStrings = prizeTables.split("|");
						
						
						for(var i = 0; i < pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								registerDebugText("Price Point " + pricePointList[i] + " table: " + prizeTableStrings[i]);
								return prizeTableStrings[i];
							}
						}
						
						return "";
					}
					
					////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// Input: The scenario data in the Json Response, the pattern Prize Values, the pattern names and the pattern def
					// Output: A string of the specific pattern wins for the entire scenario
					function retrievePatternWins(jsonContext, prizeTable, patternNames, patternDef)
					{
						var scenario = getScenario(jsonContext);
						var drawnNumbers = (scenario.split("|")[0]).split(",");
						var bingoCardData = (scenario.split("|")[1]).split(",");
						var prizePatterns = patternDef.replace(/,/g,'').split("|");
						var patternList = patternNames.split(",");
						var prizeTableList = prizeTable.split(",");
						var linePatterns = ["XXXXX--------------------",
											"-----XXXXX---------------",
											"----------XXXXX----------",
											"---------------XXXXX-----",
											"--------------------XXXXX",
											"X----X----X----X----X----",
											"-X----X----X----X----X---",
											"--X----X----X----X----X--",
											"---X----X----X----X----X-",
											"----X----X----X----X----X",
											"X-----X-----X-----X-----X",
											"----X---X---X---X---X----"];
											
						var patternWinsString = "";			
						for (var i = 0; i < patternList.length; ++i)
						{
							if(i != 0)
							{
								patternWinsString += ",";
							}
							// BlackOut,Z,X,4Corners,Line
							switch(patternList[i])
							{
								case "BlackOut":
								case "Z":
								case "X":
								case "4Corners":
									if(checkForExclusivePattern(drawnNumbers, bingoCardData, prizePatterns[i]))
									{
										patternWinsString += prizeTableList[i];
									}
									else
									{
										patternWinsString += "0";
									}
									break;
								case "Line":
									var linesAwarded = checkForLinesPattern(drawnNumbers, bingoCardData, linePatterns);
									
									if(linesAwarded != 0)
									{
										patternWinsString += (prizeTableList[i] * linesAwarded);
									}
									else
									{
										patternWinsString += "0";
									}
									break;
							}
							registerDebugText("Wins Awarded: " + patternWinsString);
						}
						
						return patternWinsString;
					}
					
					function checkForExclusivePattern(drawnNumbers, bingoCardData, prizePattern)
					{
						for(var cell = 0; cell < prizePattern.length; ++cell)
						{
							if(prizePattern[cell] == "X")
							{
								var singleMatch = false;
								for(var drawn = 0; drawn < drawnNumbers.length; ++drawn)
								{
									if(bingoCardData[cell] == "FREE" || drawnNumbers[drawn] == bingoCardData[cell])
									{
										singleMatch = true;
										break;
									}
								}
								if(!singleMatch)
									return false;
							}
						}
						
						return true;
					}
					
					function checkForLinesPattern(drawnNumbers, bingoCardData, linePatterns)
					{
						var linesAwarded = 0;
						for(var line = 0; line < linePatterns.length; ++line)
						{
							if(checkForExclusivePattern(drawnNumbers, bingoCardData, linePatterns[line]))
							{
								linesAwarded++;
								registerDebugText("Line Pattern Awarded(" + linesAwarded + "): " + linePatterns[line]);
							}
						}
						
						registerDebugText(linesAwarded);
						
						return linesAwarded;
					}
					
					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.getAttribute("key") == keyName)
							{
								return childNode.getAttribute("value");
							}
							
							index += 2;
						}
					}
					
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="SignedData/Data/Outcome/OutcomeDetail/Payout" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="bingoColumns">
					<xsl:value-of select="$bingoColumns" />
				</x:variable>
				<x:variable name="patternNames">
					<xsl:value-of select="$patternNamesString" />
				</x:variable>
				<x:variable name="patternDef">
					<xsl:value-of select="$patternDefString" />
				</x:variable>
				<x:variable name="pricePoints">
					<xsl:value-of select="$pricePointsString" />
				</x:variable>
				<x:variable name="prizeValuesAllPricePoints">
					<xsl:value-of select="$prizeTableString" />
				</x:variable>
				<x:variable name="prizeTable">
					<x:value-of select="my-ext:retrievePrizeTable($pricePoints, $prizeValuesAllPricePoints, $wageredPricePoint)" />
				</x:variable>
				<x:variable name="patternWins">
					<x:value-of select="my-ext:retrievePatternWins($odeResponseJson, $prizeTable, $patternNames, $patternDef)" />
				</x:variable>
				
				
				<x:variable name="convertedPrizeValues">
					<x:call-template name="split">
						<x:with-param name="pText" select="string($prizeTable)" />
					</x:call-template>
				</x:variable>
				<x:variable name="convertedPatternWins">
					<x:call-template name="split">
						<x:with-param name="pText" select="string($patternWins)" />
					</x:call-template>
				</x:variable>

				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $patternDef, string($convertedPrizeValues), $bingoColumns, string($convertedPatternWins), $patternNames)" disable-output-escaping="yes" />
			</x:template>

			<x:template name="split">
				<x:param name="pText" />
				<x:if test="string-length($pText)">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
						<x:with-param name="value" select="substring-before(concat($pText,','),',')" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
					<x:call-template name="split">
						<x:with-param name="pText" select="substring-after($pText,',')" />
					</x:call-template>
				</x:if>
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
