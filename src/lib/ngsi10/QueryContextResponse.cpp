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

#include "logMsg/traceLevels.h"
#include "logMsg/logMsg.h"
#include "common/string.h"
#include "common/tag.h"
#include "rest/HttpStatusCode.h"
#include "ngsi/StatusCode.h"
#include "ngsi10/QueryContextResponse.h"
#include "rest/ConnectionInfo.h"



/* ****************************************************************************
*
* QueryContextResponse::QueryContextResponse - 
*/
QueryContextResponse::QueryContextResponse()
{
  errorCode.tagSet("errorCode");
}



/* ****************************************************************************
*
* QueryContextResponse::QueryContextResponse - 
*/
QueryContextResponse::QueryContextResponse(StatusCode& _errorCode)
{
  errorCode.fill(&_errorCode);
  errorCode.tagSet("errorCode");
}



/* ****************************************************************************
*
* QueryContextResponse::QueryContextResponse - 
*/
QueryContextResponse::QueryContextResponse(EntityId* eP, ContextAttribute* aP)
{
  ContextElementResponse* cerP = new ContextElementResponse();
  ContextAttribute*       caP  = new ContextAttribute(aP);

  cerP->contextElement.entityId.fill(eP);
  cerP->contextElement.contextAttributeVector.push_back(caP);  
  cerP->statusCode.fill(SccOk);

  contextElementResponseVector.push_back(cerP);
  errorCode.fill(SccOk);
}



/* ****************************************************************************
*
* QueryContextResponse::~QueryContextResponse -
*/
QueryContextResponse::~QueryContextResponse()
{
  errorCode.release();
  contextElementResponseVector.release();
}



/* ****************************************************************************
*
* QueryContextResponse::render - 
*/
std::string QueryContextResponse::render(ConnectionInfo* ciP, RequestType requestType, const std::string& indent)
{
  std::string  out               = "";
  std::string  tag               = "queryContextResponse";
  bool         errorCodeRendered = false;
  
  //
  // 01. Decide whether errorCode should be rendered
  //
  if ((errorCode.code != SccNone) && (errorCode.code != SccOk))
  {
    errorCodeRendered = true;
  }
  else if (contextElementResponseVector.size() == 0)
  {
    errorCodeRendered = true;
  }
  else if (errorCode.details != "")
  {
    if (errorCode.code == SccNone)
    {
      errorCode.code = SccOk;
    }

    errorCodeRendered = true;
  }


  //
  // 02. render 
  //
  out += startTag(indent, tag, ciP->outFormat, false);

  if (contextElementResponseVector.size() > 0)
  {
    out += contextElementResponseVector.render(ciP, QueryContext, indent + "  ", errorCodeRendered);
  }

  if (errorCodeRendered == true)
  {
    out += errorCode.render(ciP->outFormat, indent + "  ");
  }


  //
  // 03. Safety Check
  //
  // If neither errorCode nor CER vector was filled by mongoBackend, then we
  // report a special kind of error.
  //
  if ((errorCode.code == SccNone) && (contextElementResponseVector.size() == 0))
  {
    LM_W(("Internal Error (Both error-code and response vector empty)"));
    errorCode.fill(SccReceiverInternalError, "Both the error-code structure and the response vector were empty");
    out += errorCode.render(ciP->outFormat, indent + "  ");
  }

  out += endTag(indent, tag, ciP->outFormat);

  return out;
}



/* ****************************************************************************
*
* QueryContextResponse::check -
*/
std::string QueryContextResponse::check(ConnectionInfo* ciP, RequestType requestType, const std::string& indent, const std::string& predetectedError, int counter)
{
  std::string           res;

  if (predetectedError != "")
  {
    errorCode.fill(SccBadRequest, predetectedError);
  }
  else if ((res = contextElementResponseVector.check(QueryContext, ciP->outFormat, indent, predetectedError, 0)) != "OK")
  {
    LM_W(("Bad Input (%s)", res.c_str()));
    errorCode.fill(SccBadRequest, res);
  }
  else
    return "OK";

  return render(ciP, QueryContext, indent);
}



/* ****************************************************************************
*
* QueryContextResponse::present -
*/
void QueryContextResponse::present(const std::string& indent, const std::string& caller)
{
  LM_F(("QueryContextResponse presented by %s", caller.c_str()));
  contextElementResponseVector.present(indent + "  ");
  errorCode.present(indent + "  ");
}



/* ****************************************************************************
*
* QueryContextResponse::release -
*/
void QueryContextResponse::release(void)
{
  contextElementResponseVector.release();
  errorCode.release();
}



/* ****************************************************************************
*
* QueryContextResponse::fill - 
*/
void QueryContextResponse::fill(QueryContextResponse* qcrsP)
{
  errorCode.fill(qcrsP->errorCode);

  for (unsigned int cerIx = 0; cerIx < qcrsP->contextElementResponseVector.size(); ++cerIx)
  {
    ContextElementResponse* cerP = new ContextElementResponse();

    cerP->fill(qcrsP->contextElementResponseVector[cerIx]);

    contextElementResponseVector.push_back(cerP);
  }
}



/* ****************************************************************************
*
* QueryContextResponse::clone - 
*/
QueryContextResponse* QueryContextResponse::clone(void)
{
  QueryContextResponse* clon = new QueryContextResponse();

  clon->fill(this);

  return clon;
}
