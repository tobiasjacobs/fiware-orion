#ifndef SRC_LIB_CACHE_SUBSCRIPTIONCACHE_H_
#define SRC_LIB_CACHE_SUBSCRIPTIONCACHE_H_

/*
*
* Copyright 2015 Telefonica Investigacion y Desarrollo, S.A.U
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
#include <semaphore.h>
#include <regex.h>
#include <string>
#include <vector>

#include "ngsi/Restriction.h"
#include "ngsi/Reference.h"
#include "ngsi/NotifyConditionVector.h"
#include "ngsi/EntityId.h"
#include "ngsi/ContextAttribute.h"

namespace orion
{



/* ****************************************************************************
*
* EntityInfo - 
*
* The struct fields:
* -------------------------------------------------------------------------------
* o entityIdPattern      regex describing EntityId::id (OMA NGSI type)
* o entityType           string containing the type of the EntityId
*
*/
struct EntityInfo
{
  regex_t       entityIdPattern;
  std::string   entityType;
};



/* ****************************************************************************
*
* SubscriptionCache -
*
* The class fields:
* -------------------------------------------------------------------------------
* o subscriptionId         the subscription ID from the database
* o entityIdInfos          list of EntityInfo
* o attributes             list of strings of attribute names
* o throttling             throttling time in seconds
* o expirationTime         expiration time expressed as Unix seconds since epoch
* o restriction            Restriction (OMA NGSI type)
* o notifyConditionVector  list of NotifyCondition (OMA NGSI type)
* o Reference              Info on the receiver of the notification
*
*/
class Subscription
{
  std::string               subscriptionId;
  std::vector<EntityInfo*>  entityIdInfos;
  std::vector<std::string>  attributes;
  int64                     throttling;
  int64                     expirationTime;
  Restriction               restriction;
  NotifyConditionVector     notifyConditionVector;
  Reference                 reference;
};



/* ****************************************************************************
*
* SubscriptionCache -
*
* The class fields:
* -------------------------------------------------------------------------------
*   subs:            the vector of Subscriptions
*   mutex:           binary semaphore protecting 'subs'
*
*   init():          at startup, fill cache from database
*   insert():        insert/modify a Subscription in 'subs'
*   delete():        delete a Subscription from 'subs'
*   refresh():       synchronize cache with DB
*   lookup():        find a subscription based on entity and attribute
*   lookupById():    find a subscription based on subscriptionId
*
*/
class SubscriptionCache
{
 private:
  std::vector<Subscription*>  subs;
  sem_t                       mutex;

 public:
  SubscriptionCache();

  int            init(void);
  void           insert(const Subscription& sub);
  int            delete(std::string subId);
  int            refresh(void);
  Subscription*  lookup(const EntityId& entity, const ContextAttribute& attribute);
  Subscription*  lookupById(std::string subId);
};

}  // namespace orion

#endif  // SRC_LIB_CACHE_SUBSCRIPTIONCACHE_H_