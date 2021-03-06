/*
*
* Copyright 2013 Telefonica Investigacion y Desarrollo, S.A.U
*
* This file is part of Orion Context Broker.
*
* Orion Context Broker is free software: you can redistribute it and/or
* modify it under the terms of the GNU Affero General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Orion Context Broker is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
* General Public License for more details.
*
* You should have received a copy of the GNU Affero General Public License
* along with Orion Context Broker. If not, see http://www.gnu.org/licenses/.
*
* For those usages not covered by this license please contact with
* iot_support at tid dot es
*
* Author: Ken Zangelin
*/
#include <string>

#include "logMsg/logMsg.h"
#include "logMsg/traceLevels.h"

#include "common/globals.h"
#include "common/tag.h"
#include "ngsi/Request.h"
#include "ngsi/Restriction.h"



/* ****************************************************************************
*
* Restriction::check -
*/
std::string Restriction::check
(
  RequestType         requestType,
  Format              format,
  const std::string&  indent,
  const std::string&  predetectedError,
  int                 counter
)
{
  std::string res;

  LM_T(LmtRestriction, ("In Restriction::check"));
  if (counter == 0)  // Restriction is always optional
  {
    LM_T(LmtRestriction, ("Restriction::check returns OK (counter == 0)"));
    return "OK";
  }

  if ((scopeVector.size() == 0) && (attributeExpression.isEmpty()))
  {
    LM_W(("Bad Input (empty restriction)"));
    return "empty restriction";
  }

  if (((res = scopeVector.check(requestType, format, indent, predetectedError,  counter))         != "OK") ||
      ((res = attributeExpression.check(requestType, format, indent, predetectedError,  counter)) != "OK"))
  {
    LM_T(LmtRestriction, ("Restriction::check returns '%s'", res.c_str()));
    LM_W(("Bad Input (%s)", res.c_str()));

    return res;
  }

  LM_T(LmtRestriction, ("Restriction::check returns OK (2)"));
  return "OK";
}



/* ****************************************************************************
*
* Restriction::present -
*/
void Restriction::present(const std::string& indent)
{
  attributeExpression.present(indent);
  scopeVector.present(indent);
}



/* ****************************************************************************
*
* Restriction::render -
*/
std::string Restriction::render(Format format, const std::string& indent, int restrictions, bool comma)
{
  std::string  tag = "restriction";
  std::string  out = "";
  bool         scopeVectorRendered = scopeVector.size() != 0;

  if (restrictions == 0)
  {
    return "";
  }

  out += startTag(indent, tag, format);
  out += attributeExpression.render(format, indent + "  ", scopeVectorRendered);
  out += scopeVector.render(format, indent + "  ", false);
  out += endTag(indent, tag, format, comma);

  return out;
}



/* ****************************************************************************
*
* Restriction::release -
*/
void Restriction::release(void)
{
  attributeExpression.release();
  scopeVector.release();
}



/* ****************************************************************************
*
* Restriction::fill - 
*/
void Restriction::fill(Restriction* rP)
{
  const std::string ae = rP->attributeExpression.get();
  attributeExpression.set(ae);

  for (unsigned int ix = 0; ix < rP->scopeVector.size(); ++ix)
  {
    scopeVector.push_back(new Scope(rP->scopeVector[ix]->type, rP->scopeVector[ix]->value, rP->scopeVector[ix]->oper));
  }
}
