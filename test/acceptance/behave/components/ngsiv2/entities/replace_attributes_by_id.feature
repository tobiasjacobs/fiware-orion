# -*- coding: utf-8 -*-

# Copyright 2015 Telefonica Investigacion y Desarrollo, S.A.U
#
# This file is part of Orion Context Broker.
#
# Orion Context Broker is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Orion Context Broker is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
# General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Orion Context Broker. If not, see http://www.gnu.org/licenses/.
#
# For those usages not covered by this license please contact with
# iot_support at tid dot es
#
# author: 'Iván Arias León (ivan dot ariasleon at telefonica dot com)'

#
#  Note: the "skip" tag is to skip the scenarios that still are not developed or failed
#        -tg=-skip
#


Feature: replace attributes by entity ID using NGSI v2. "PUT" - /v2/entities/<entity_id> plus payload
  As a context broker user
  I would like to replace attributes by entity ID using NGSI v2
  So that I can manage and use them in my scripts

  Actions Before the Feature:
     Setup: update properties test file from "epg_contextBroker.txt" and sudo local "false"
     Setup: update contextBroker config file
     Setup: start ContextBroker
     Check: verify contextBroker is installed successfully
     Check: verify mongo is installed successfully

  Actions After each Scenario:
     Setup: delete database in mongo

  Actions After the Feature:
     Setup: stop ContextBroker

  @happy_path
  Scenario:  replace attributes by entity ID using NGSI v2
    Given  a definition of headers
      | parameter          | value                   |
      | Fiware-Service     | test_replace_happy_path |
      | Fiware-ServicePath | /test                   |
      | Content-Type       | application/json        |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter         | value      |
      | attributes_number | 5          |
      | attributes_name   | humidity   |
      | attributes_value  | 80         |
      | attributes_type   | Fahrenheit |
      | metadatas_number  | 3          |
      | metadatas_name    | very_cold  |
      | metadatas_type    | alarm      |
      | metadatas_value   | cold       |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo

  @more_entities_replace @BUG_1320
  Scenario:  try to replace attributes by entity ID using NGSI v2 with more than one entity with the same id
    Given  a definition of headers
      | parameter          | value                      |
      | Fiware-Service     | test_replace_more_entities |
      | Fiware-ServicePath | /test                      |
      | Content-Type       | application/json           |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
    And verify that receive several "Created" http code
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | home        |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 45          |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value         |
      | attributes_name  | temperature_0 |
      | attributes_value | 80            |
    Then verify that receive an "Conflict" http code
    And verify an error response
      | parameter   | value                                                                          |
      | error       | TooManyResults                                                                 |
      | description | There is more than one entity that match the update. Please refine your query. |

  @length_required
  Scenario:  try to replace attributes by entity ID using NGSI v2 without payload
    Given  a definition of headers
      | parameter          | value                        |
      | Fiware-Service     | test_replace_length_required |
      | Fiware-ServicePath | /test                        |
      | Content-Type       | application/json             |
    When replace attributes by ID "room"
    Then verify that receive an "Length Required" http code
    And verify an error response
      | parameter   | value                                            |
      | error       | LengthRequired                                   |
      | description | Zero/No Content-Length in PUT/POST/PATCH request |

  @maximum_size
    # 5023 attributes is a way of generating a request longer than 1MB (in fact, 1048697 bytes)
  Scenario:  try to replace attributes using NGSI v2 with maximum size in payload (5023 attributes = 1048697 bytes)
    Given  a definition of headers
      | parameter          | value             |
      | Fiware-Service     | test_maximum_size |
      | Fiware-ServicePath | /test             |
      | Content-Type       | application/json  |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
    When replace attributes by ID "room"
      | parameter         | value       |
      | attributes_number | 5023        |
      | attributes_name   | temperature |
      | attributes_value  | 80          |
      | attributes_type   | Fahrenheit  |
      | metadatas_number  | 3           |
      | metadatas_name    | very_hot    |
      | metadatas_type    | alarm       |
      | metadatas_value   | cold        |
    Then verify that receive an "Request Entity Too Large" http code
    And verify an error response
      | parameter   | value                                              |
      | error       | RequestEntityTooLarge                              |
      | description | payload size: 1048697, max size supported: 1048576 |

  @multiple_attributes
  Scenario Outline:  replace multiples attributes by entity ID using NGSI v2
    Given  a definition of headers
      | parameter          | value                    |
      | Fiware-Service     | test_replace_multi_attrs |
      | Fiware-ServicePath | /test                    |
      | Content-Type       | application/json         |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter         | value               |
      | attributes_number | <attributes_number> |
      | attributes_name   | humidity            |
      | attributes_value  | 80                  |
      | attributes_type   | Fahrenheit          |
      | metadatas_number  | 1                   |
      | metadatas_name    | very_cold           |
      | metadatas_type    | alarm               |
      | metadatas_value   | cold                |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_number |
      | 2                 |
      | 10                |
      | 50                |
      | 100               |
      | 500               |

  @multiple_attributes_metadatas
  Scenario Outline:  replace multiples attributes metadatas by entity ID using NGSI v2
    Given  a definition of headers
      | parameter          | value                         |
      | Fiware-Service     | test_replace_multi_attrs_meta |
      | Fiware-ServicePath | /test                         |
      | Content-Type       | application/json              |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter         | value             |
      | attributes_number | 1                 |
      | attributes_name   | humidity          |
      | attributes_value  | 80                |
      | attributes_type   | Fahrenheit        |
      | metadatas_number  | <metadata_number> |
      | metadatas_name    | very_cold         |
      | metadatas_type    | alarm             |
      | metadatas_value   | cold              |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | metadata_number |
      | 2               |
      | 10              |
      | 50              |
      | 100             |
      | 500             |

   # ------------------------ Service ----------------------------------------------
  @service_replace
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several service header values
    Given  a definition of headers
      | parameter          | value            |
      | Fiware-Service     | <service>        |
      | Fiware-ServicePath | /test            |
      | Content-Type       | application/json |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value    |
      | attributes_name  | humidity |
      | attributes_value | 80       |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | service            |
      |                    |
      | service            |
      | service_12         |
      | service_sr         |
      | SERVICE            |
      | max length allowed |

  @service_replace_without
  Scenario:  replace attributes by entity ID using NGSI v2 without service header
    Given  a definition of headers
      | parameter          | value            |
      | Fiware-ServicePath | /test            |
      | Content-Type       | application/json |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value    |
      | attributes_name  | humidity |
      | attributes_value | 80       |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo

  @service_replace_error
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with wrong service header values
    Given  a definition of headers
      | parameter          | value            |
      | Fiware-Service     | <service>        |
      | Fiware-ServicePath | /test            |
      | Content-Type       | application/json |
    When replace attributes by ID "room"
      | parameter        | value       |
      | attributes_name  | temperature |
      | attributes_value | 80          |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                                                                                                                         |
      | error       | BadRequest                                                                                                                                    |
      | description | tenant name not accepted - a tenant string must not be longer than 50 characters and may only contain underscores and alphanumeric characters |
    Examples:
      | service                         |
      | service.sr                      |
      | Service-sr                      |
      | Service(sr)                     |
      | Service=sr                      |
      | Service<sr>                     |
      | Service,sr                      |
      | greater than max length allowed |

  # ------------------------ Service path ----------------------------------------------

  @service_path_replace
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several service header values
    Given  a definition of headers
      | parameter          | value                     |
      | Fiware-Service     | test_replace_service_path |
      | Fiware-ServicePath | <service_path>            |
      | Content-Type       | application/json          |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value    |
      | attributes_name  | humidity |
      | attributes_value | 80       |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | service_path                                                  |
      |                                                               |
      | /                                                             |
      | /service_path                                                 |
      | /service_path_12                                              |
      | /Service_path                                                 |
      | /SERVICE                                                      |
      | /serv1/serv2/serv3/serv4/serv5/serv6/serv7/serv8/serv9/serv10 |
      | max length allowed                                            |
      | max length allowed and ten levels                             |

  @service_path_replace_without
  Scenario:  replace attributes by entity ID using NGSI v2 without service header
    Given  a definition of headers
      | parameter      | value                     |
      | Fiware-Service | test_replace_service_path |
      | Content-Type   | application/json          |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value    |
      | attributes_name  | humidity |
      | attributes_value | 80       |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo

  @service_path_replace_error
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with wrong service header values
    Given  a definition of headers
      | parameter          | value                           |
      | Fiware-Service     | test_replace_service_path_error |
      | Fiware-ServicePath | <service_path>                  |
      | Content-Type       | application/json                |
    When replace attributes by ID "room"
      | parameter        | value       |
      | attributes_name  | temperature |
      | attributes_value | 80          |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                                    |
      | error       | BadRequest                                               |
      | description | a component of ServicePath contains an illegal character |
    Examples:
      | service_path |
      | /service.sr  |
      | /service;sr  |
      | /service=sr  |
      | /Service-sr  |
      | /serv<45>    |
      | /serv(45)    |

  @service_path_replace_error
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with wrong service header values
    Given  a definition of headers
      | parameter          | value                           |
      | Fiware-Service     | test_replace_service_path_error |
      | Fiware-ServicePath | <service_path>                  |
      | Content-Type       | application/json                |
    When replace attributes by ID "room"
      | parameter        | value       |
      | attributes_name  | temperature |
      | attributes_value | 80          |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                                                    |
      | error       | BadRequest                                                               |
      | description | Only /absolute/ Service Paths allowed [a service path must begin with /] |
    Examples:
      | service_path |
      | sdffsfs      |
      | /service,sr  |

  @service_path_replace_error
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with wrong service header values
    Given  a definition of headers
      | parameter          | value                           |
      | Fiware-Service     | test_replace_service_path_error |
      | Fiware-ServicePath | <service_path>                  |
      | Content-Type       | application/json                |
    When replace attributes by ID "room"
      | parameter        | value       |
      | attributes_name  | temperature |
      | attributes_value | 80          |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                  |
      | error       | BadRequest                             |
      | description | component-name too long in ServicePath |
    Examples:
      | service_path                                   |
      | greater than max length allowed                |
      | greater than max length allowed and ten levels |

  @service_path_replace_error
  Scenario:  try to replace attributes by entity ID using NGSI v2 with wrong service header values
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_replace_service_path_error      |
      | Fiware-ServicePath | max length allowed and eleven levels |
      | Content-Type       | application/json                     |
    When replace attributes by ID "room"
      | parameter        | value       |
      | attributes_name  | temperature |
      | attributes_value | 80          |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                              |
      | error       | BadRequest                         |
      | description | too many components in ServicePath |

 #  -------------------------- entity id --------------------------------------------------

  @entity_id_replace
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several entity id values
    Given  a definition of headers
      | parameter          | value                  |
      | Fiware-Service     | test_replace_entity_id |
      | Fiware-ServicePath | /test                  |
      | Content-Type       | application/json       |
    And create "1" entities with "3" attributes
      | parameter        | value         |
      | entities_type    | <entity_type> |
      | entities_id      | <entity_id>   |
      | attributes_name  | temperature   |
      | attributes_value | 34            |
      | attributes_type  | celcius       |
      | metadatas_number | 2             |
      | metadatas_name   | very_hot      |
      | metadatas_type   | alarm         |
      | metadatas_value  | hot           |
    And verify that receive several "Created" http code
    When replace attributes by ID "the same value of the previous request"
      | parameter        | value    |
      | attributes_name  | pressure |
      | attributes_value | 80       |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | entity_type | entity_id  |
      | room_1      | room       |
      | room_2      | 34         |
      | room_3      | false      |
      | room_4      | true       |
      | room_5      | 34.4E-34   |
      | room_6      | temp.34    |
      | room_7      | temp_34    |
      | room_8      | temp-34    |
      | room_9      | TEMP34     |
      | room_10     | house_flat |
      | room_11     | house.flat |
      | room_12     | house-flat |
      | room_13     | house@flat |
      | room_14     | habitación |
      | room_15     | españa     |
      | room_16     | barça      |
      | room_17     | random=10  |
      | room_18     | random=100 |
      | room_19     | random=960 |

  @entity_id_unknown @BUG_1320 @skip
  Scenario:  try to replace attributes by entity ID using NGSI v2 with unknown entity id values
    Given  a definition of headers
      | parameter          | value                          |
      | Fiware-Service     | test_replace_entity_id_unknown |
      | Fiware-ServicePath | /test                          |
      | Content-Type       | application/json               |
    And create "5" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room3       |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "fdgdfgdf"
      | parameter        | value    |
      | attributes_name  | pressure |
      | attributes_value | 80       |
    Then verify that receive an "Not Found" http code
    And verify an error response
      | parameter   | value                    |
      | error       | NotFound                 |
      | description | No context element found |

  @entity_id_replace_invalid
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with invalid entity id values
    Given  a definition of headers
      | parameter          | value                  |
      | Fiware-Service     | test_replace_entity_id |
      | Fiware-ServicePath | /test                  |
      | Content-Type       | application/json       |
    When replace attributes by ID "<entity_id>"
      | parameter        | value       |
      | attributes_name  | temperature |
      | attributes_value | 80          |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                    |
      | error       | BadRequest               |
      | description | invalid character in URI |
    Examples:
      | entity_id           |
      | house<flat>         |
      | house=flat          |
      | house'flat'         |
      | house\'flat\'       |
      | house;flat          |
      | house(flat)         |
      | {\'a\':34}          |
      | [\'34\', \'a\', 45] |

  # --------------------- attribute name  ------------------------------------

  @attribute_name_replace @BUG_1323
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute names
    Given  a definition of headers
      | parameter          | value                       |
      | Fiware-Service     | test_attribute_name_replace |
      | Fiware-ServicePath | /test                       |
      | Content-Type       | application/json            |
    And create "1" entities with "1" attributes
      | parameter        | value    |
      | entities_type    | house    |
      | entities_id      | room     |
      | attributes_name  | pressure |
      | attributes_value | 34       |
      | attributes_type  | celcius  |
      | metadatas_number | 2        |
      | metadatas_name   | very_hot |
      | metadatas_type   | alarm    |
      | metadatas_value  | hot      |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value             |
      | attributes_name  | <attributes_name> |
      | attributes_value | 80                |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_name |
      | temperature     |
      | temp.48         |
      | temp_49         |
      | temp-50         |
      | TEMP51          |
      | house_flat      |
      | house.flat      |
      | house-flat      |
      | house@flat      |
      | habitación      |
      | españa          |
      | barça           |
      | random=10       |
      | random=100      |
      | random=10000    |
      | random=100000   |

  @attribute_name_invalid
  Scenario Outline:  try to replace attributes using NGSI v2 API with invalid attribute names
    Given  a definition of headers
      | parameter          | value                             |
      | Fiware-Service     | test_attribute_name_replace_error |
      | Fiware-ServicePath | /test                             |
      | Content-Type       | application/json                  |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value             |
      | attributes_name  | <attributes_name> |
      | attributes_value | 80                |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | BadRequest                           |
      | description | Invalid characters in attribute name |
    Examples:
      | entity_id | attributes_name |
      | room_2    | house<flat>     |
      | room_3    | house=flat      |
      | room_4    | house"flat"     |
      | room_5    | house'flat'     |
      | room_6    | house;flat      |
      | room_8    | house(flat)     |

  @attribute_name_replace_error
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with invalid attribute names
    Given  a definition of headers
      | parameter          | value                             |
      | Fiware-Service     | test_attribute_name_replace_error |
      | Fiware-ServicePath | /test                             |
      | Content-Type       | application/json                  |
    When replace attributes by ID "room" in raw mode
      | parameter        | value             |
      | attributes_name  | <attributes_name> |
      | attributes_value | true              |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | ParseError                           |
      | description | Errors found in incoming JSON buffer |
    Examples:
      | attributes_name |
      | rewrewr         |
      | SDFSDFSDF       |
      | false           |
      | true            |
      | 34              |
      | {"a":34}        |
      | ["34", "a", 45] |
      | null            |

  @attribute_name_empty
  Scenario:  try to replace attribute using NGSI v2 API with empty attribute name
    Given  a definition of headers
      | parameter          | value                             |
      | Fiware-Service     | test_attribute_name_replace_error |
      | Fiware-ServicePath | /test                             |
      | Content-Type       | application/json                  |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value |
      | attributes_name  |       |
      | attributes_value | 80    |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                          |
      | error       | ParseError                     |
      | description | no 'name' for ContextAttribute |

  # --------------------- attribute value  ------------------------------------

  @attribute_value_replace_without_attribute_type
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute values and without attribute type nor metadatas
    Given  a definition of headers
      | parameter          | value                                     |
      | Fiware-Service     | test_replace_attr_value_without_attr_type |
      | Fiware-ServicePath | /test                                     |
      | Content-Type       | application/json                          |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 56          |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value              |
      | attributes_name  | pressure           |
      | attributes_value | <attributes_value> |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_value |
      | fdgdfgfd         |
      | 34               |
      | 34.4E-34         |
      | temp.34          |
      | temp_34          |
      | temp-34          |
      | TEMP34           |
      | house_flat       |
      | house.flat       |
      | house-flat       |
      | house@flat       |
      | habitación       |
      | españa           |
      | barça            |
      | random=10        |
      | random=100       |
      | random=1000      |
      | random=10000     |
      | random=100000    |

  @attribute_value_replace_with_attribute_type
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute values and with attribute type
    Given  a definition of headers
      | parameter          | value                                  |
      | Fiware-Service     | test_replace_attr_value_with_attr_type |
      | Fiware-ServicePath | /test                                  |
      | Content-Type       | application/json                       |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value              |
      | attributes_name  | pressure           |
      | attributes_value | <attributes_value> |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_value |
      | gsdfggff         |
      | 34               |
      | 34.4E-34         |
      | temp.34          |
      | temp_34          |
      | temp-34          |
      | TEMP34           |
      | house_flat       |
      | house.flat       |
      | house-flat       |
      | house@flat       |
      | habitación       |
      | españa           |
      | barça            |
      | random=10        |
      | random=100       |
      | random=1000      |
      | random=10000     |
      | random=100000    |

  @attribute_value_replace_with_metadatas
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute values and with metadatas
    Given  a definition of headers
      | parameter          | value                                 |
      | Fiware-Service     | test_replace_attr_value_with_metadata |
      | Fiware-ServicePath | /test                                 |
      | Content-Type       | application/json                      |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value              |
      | attributes_name  | pressure           |
      | attributes_value | <attributes_value> |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_value |
      | tytryrty         |
      | 34               |
      | 34.4E-34         |
      | temp.34          |
      | temp_34          |
      | temp-34          |
      | TEMP34           |
      | house_flat       |
      | house.flat       |
      | house-flat       |
      | house@flat       |
      | habitación       |
      | españa           |
      | barça            |
      | random=10        |
      | random=100       |
      | random=1000      |
      | random=10000     |
      | random=100000    |

  @attribute_value_replace_without_attribute_type_special @BUG_1106 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with special attribute values (compound, vector, boolean, etc) and without attribute type nor metadatas
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_replace_attribute_value_special |
      | Fiware-ServicePath | /test                                |
      | Content-Type       | application/json                     |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 45          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter        | value              |
      | attributes_name  | "pressure"         |
      | attributes_value | <attributes_value> |
    Then verify that receive an "No Content" http code
    Examples:
      | entity_id | attributes_value                                                              |
      | room1     | true                                                                          |
      | room2     | false                                                                         |
      | room3     | 34                                                                            |
      | room4     | -34                                                                           |
      | room5     | 5.00002                                                                       |
      | room6     | -5.00002                                                                      |
      | room7     | [ "json", "vector", "of", 6, "strings", "and", 2, "integers" ]                |
      | room8     | [ "json", ["a", 34, "c", ["r", 4, "t"]], "of", 6]                             |
      | room9     | [ "json", ["a", 34, "c", {"r": 4, "t":"4", "h":{"s":"3", "g":"v"}}], "of", 6] |
      | room10    | {"x": "x1","x2": "b"}                                                         |
      | room11    | {"x": {"x1": "a","x2": "b"}}                                                  |
      | room12    | {"a":{"b":{"c":{"d": {"e": {"f": 34}}}}}}                                     |
      | room13    | {"x": ["a", 45, "rt"],"x2": "b"}                                              |
      | room14    | {"x": [{"a":78, "b":"r"}, 45, "rt"],"x2": "b"}                                |
      | room15    | "41.3763726, 2.1864475,14"                                                    |
      | room16    | "2017-06-17T07:21:24.238Z"                                                    |
      | room17    | null                                                                          |

  @attribute_value_replace_with_attribute_type_special @BUG_1106 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with special attribute values (compound, vector, boolean, etc) and with attribute type
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_replace_attribute_value_special |
      | Fiware-ServicePath | /test                                |
      | Content-Type       | application/json                     |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 67          |
      | attributes_type  | celcius     |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter        | value              |
      | attributes_name  | "pressure"         |
      | attributes_value | <attributes_value> |
    Then verify that receive an "No Content" http code
    Examples:
      | entity_id | attributes_value                                                              |
      | room1     | true                                                                          |
      | room2     | false                                                                         |
      | room3     | 34                                                                            |
      | room4     | -34                                                                           |
      | room5     | 5.00002                                                                       |
      | room6     | -5.00002                                                                      |
      | room7     | [ "json", "vector", "of", 6, "strings", "and", 2, "integers" ]                |
      | room8     | [ "json", ["a", 34, "c", ["r", 4, "t"]], "of", 6]                             |
      | room9     | [ "json", ["a", 34, "c", {"r": 4, "t":"4", "h":{"s":"3", "g":"v"}}], "of", 6] |
      | room10    | {"x": "x1","x2": "b"}                                                         |
      | room11    | {"x": {"x1": "a","x2": "b"}}                                                  |
      | room12    | {"a":{"b":{"c":{"d": {"e": {"f": 34}}}}}}                                     |
      | room13    | {"x": ["a", 45, "rt"],"x2": "b"}                                              |
      | room14    | {"x": [{"a":78, "b":"r"}, 45, "rt"],"x2": "b"}                                |
      | room15    | "41.3763726, 2.1864475,14"                                                    |
      | room16    | "2017-06-17T07:21:24.238Z"                                                    |
      | room17    | null                                                                          |

  @attribute_value_replace_with_metadata_special @BUG_1106 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with special attribute values (compound, vector, boolean, etc) and with metadatas
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_replace_attribute_value_special |
      | Fiware-ServicePath | /test                                |
      | Content-Type       | application/json                     |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter        | value              |
      | attributes_name  | "pressure"         |
      | attributes_value | <attributes_value> |
    Then verify that receive an "No Content" http code
    Examples:
      | entity_id | attributes_value                                                              |
      | room1     | true                                                                          |
      | room2     | false                                                                         |
      | room3     | 34                                                                            |
      | room4     | -34                                                                           |
      | room5     | 5.00002                                                                       |
      | room6     | -5.00002                                                                      |
      | room7     | [ "json", "vector", "of", 6, "strings", "and", 2, "integers" ]                |
      | room8     | [ "json", ["a", 34, "c", ["r", 4, "t"]], "of", 6]                             |
      | room9     | [ "json", ["a", 34, "c", {"r": 4, "t":"4", "h":{"s":"3", "g":"v"}}], "of", 6] |
      | room10    | {"x": "x1","x2": "b"}                                                         |
      | room11    | {"x": {"x1": "a","x2": "b"}}                                                  |
      | room12    | {"a":{"b":{"c":{"d": {"e": {"f": 34}}}}}}                                     |
      | room13    | {"x": ["a", 45, "rt"],"x2": "b"}                                              |
      | room14    | {"x": [{"a":78, "b":"r"}, 45, "rt"],"x2": "b"}                                |
      | room15    | "41.3763726, 2.1864475,14"                                                    |
      | room16    | "2017-06-17T07:21:24.238Z"                                                    |
      | room17    | null                                                                          |

  @attribute_value_replace_with_attribute_type_in_replace
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute values and without attribute type nor metadatas, but with attribute type in replace request
    Given  a definition of headers
      | parameter          | value                                             |
      | Fiware-Service     | test_replace_attr_value_with_attr_type_in_replace |
      | Fiware-ServicePath | /test                                             |
      | Content-Type       | application/json                                  |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 56          |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value              |
      | attributes_name  | pressure           |
      | attributes_value | <attributes_value> |
      | attributes_type  | celcius            |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_value |
      | 34               |
      | 34.4E-34         |
      | temp.34          |
      | temp_34          |
      | temp-34          |
      | TEMP34           |
      | house_flat       |
      | house.flat       |
      | house-flat       |
      | house@flat       |
      | habitación       |
      | españa           |
      | barça            |
      | random=10        |
      | random=100       |
      | random=1000      |
      | random=10000     |
      | random=100000    |

  @attribute_value_replace_special_with_attr_type @BUG_1106 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with special attribute values (compound, vector, boolean, etc) without attribute type not metadata but with attribute type in replace request
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_replace_attribute_value_special |
      | Fiware-ServicePath | /test                                |
      | Content-Type       | application/json                     |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 45          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter        | value              |
      | attributes_name  | "pressure"         |
      | attributes_value | <attributes_value> |
      | attributes_type  | "celcius"          |
    Then verify that receive an "No Content" http code
    Examples:
      | entity_id | attributes_value                                                              |
      | room1     | true                                                                          |
      | room2     | false                                                                         |
      | room3     | 34                                                                            |
      | room4     | -34                                                                           |
      | room5     | 5.00002                                                                       |
      | room6     | -5.00002                                                                      |
      | room7     | [ "json", "vector", "of", 6, "strings", "and", 2, "integers" ]                |
      | room8     | [ "json", ["a", 34, "c", ["r", 4, "t"]], "of", 6]                             |
      | room9     | [ "json", ["a", 34, "c", {"r": 4, "t":"4", "h":{"s":"3", "g":"v"}}], "of", 6] |
      | room10    | {"x": "x1","x2": "b"}                                                         |
      | room11    | {"x": {"x1": "a","x2": "b"}}                                                  |
      | room12    | {"a":{"b":{"c":{"d": {"e": {"f": 34}}}}}}                                     |
      | room13    | {"x": ["a", 45, "rt"],"x2": "b"}                                              |
      | room14    | {"x": [{"a":78, "b":"r"}, 45, "rt"],"x2": "b"}                                |
      | room15    | "41.3763726, 2.1864475,14"                                                    |
      | room16    | "2017-06-17T07:21:24.238Z"                                                    |
      | room17    | null                                                                          |

  @attribute_value_replace_with_metadata
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute values and without attribute type nor metadatas, but with metadatas in replace request
    Given  a definition of headers
      | parameter          | value                             |
      | Fiware-Service     | test_replace_attr_value_with_meta |
      | Fiware-ServicePath | /test                             |
      | Content-Type       | application/json                  |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 56          |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter        | value              |
      | attributes_name  | pressure           |
      | attributes_value | <attributes_value> |
      | metadatas_number | 2                  |
      | metadatas_name   | very_hot           |
      | metadatas_type   | alarm              |
      | metadatas_value  | hot                |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_value |
      | 34               |
      | 34.4E-34         |
      | temp.34          |
      | temp_34          |
      | temp-34          |
      | TEMP34           |
      | house_flat       |
      | house.flat       |
      | house-flat       |
      | house@flat       |
      | habitación       |
      | españa           |
      | barça            |
      | random=10        |
      | random=100       |
      | random=1000      |
      | random=10000     |
      | random=100000    |

  @attribute_value_replace_special_with_metadata @BUG_1106 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with special attribute values (compound, vector, boolean, etc) without attribute type not metadata but with metadatas in replace
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_replace_attribute_value_special |
      | Fiware-ServicePath | /test                                |
      | Content-Type       | application/json                     |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 45          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter        | value              |
      | attributes_name  | "pressure"         |
      | attributes_value | <attributes_value> |
      | metadatas_number | 2                  |
      | metadatas_name   | "very_hot"         |
      | metadatas_type   | "alarm"            |
      | metadatas_value  | "hot"              |
    Then verify that receive an "No Content" http code
    Examples:
      | entity_id | attributes_value                                                              |
      | room1     | true                                                                          |
      | room2     | false                                                                         |
      | room3     | 34                                                                            |
      | room4     | -34                                                                           |
      | room5     | 5.00002                                                                       |
      | room6     | -5.00002                                                                      |
      | room7     | [ "json", "vector", "of", 6, "strings", "and", 2, "integers" ]                |
      | room8     | [ "json", ["a", 34, "c", ["r", 4, "t"]], "of", 6]                             |
      | room9     | [ "json", ["a", 34, "c", {"r": 4, "t":"4", "h":{"s":"3", "g":"v"}}], "of", 6] |
      | room10    | {"x": "x1","x2": "b"}                                                         |
      | room11    | {"x": {"x1": "a","x2": "b"}}                                                  |
      | room12    | {"a":{"b":{"c":{"d": {"e": {"f": 34}}}}}}                                     |
      | room13    | {"x": ["a", 45, "rt"],"x2": "b"}                                              |
      | room14    | {"x": [{"a":78, "b":"r"}, 45, "rt"],"x2": "b"}                                |
      | room15    | "41.3763726, 2.1864475,14"                                                    |
      | room16    | "2017-06-17T07:21:24.238Z"                                                    |
      | room17    | null                                                                          |

  @attribute_value_error_without
  Scenario:  try to replace attributes by entity ID using NGSI v2 without attribute values
    Given  a definition of headers
      | parameter          | value                         |
      | Fiware-Service     | test_replace_attr_value_error |
      | Fiware-ServicePath | /test                         |
      | Content-Type       | application/json              |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 56          |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter       | value    |
      | attributes_name | pressure |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                  |
      | error       | ParseError                             |
      | description | invalid JSON type for ContextAttribute |

  @attribute_value_invalid
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 without invalid attribute values in replace request
    Given  a definition of headers
      | parameter          | value                         |
      | Fiware-Service     | test_replace_attr_value_error |
      | Fiware-ServicePath | /test                         |
      | Content-Type       | application/json              |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 56          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>"
      | parameter        | value              |
      | attributes_name  | pressure           |
      | attributes_value | <attributes_value> |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                 |
      | error       | BadRequest                            |
      | description | Invalid characters in attribute value |
    Examples:
      | entity_id | attributes_value |
      | room_2    | house<flat>      |
      | room_3    | house=flat       |
      | room_4    | house"flat"      |
      | room_5    | house'flat'      |
      | room_6    | house;flat       |
      | room_8    | house(flat)      |

  @attribute_value_error_special
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with wrong attribute values in replace request (compound, vector, boolean, etc)
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_replace_attribute_value_special |
      | Fiware-ServicePath | /test                                |
      | Content-Type       | application/json                     |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 45          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter        | value              |
      | attributes_name  | "pressure"         |
      | attributes_value | <attributes_value> |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | ParseError                           |
      | description | Errors found in incoming JSON buffer |
    Examples:
      | entity_id | attributes_value |
      | room_1    | rwerwer          |
      | room_2    | True             |
      | room_3    | TRUE             |
      | room_4    | False            |
      | room_5    | FALSE            |
      | room_6    | 34r              |
      | room_7    | 5_34             |
      | room_8    | ["a", "b"        |
      | room_9    | ["a" "b"]        |
      | room_10   | "a", "b"]        |
      | room_11   | ["a" "b"}        |
      | room_12   | {"a": "b"        |
      | room_13   | {"a" "b"}        |
      | room_14   | "a": "b"}        |

  @attribute_value_error_special @BUG_1217 @skip
  Scenario Outline:  try to replace attribute by entity ID using NGSI v2 with a dot in attribute values as compound in replace request (compound, vector, boolean, etc)
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_replace_attribute_value_special |
      | Fiware-ServicePath | /test                                |
      | Content-Type       | application/json                     |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 45          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter        | value              |
      | attributes_name  | "temperature_0"    |
      | attributes_value | <attributes_value> |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | ParseError                           |
      | description | Errors found in incoming JSON buffer |
    Examples:
      | entity_id | attributes_value  |
      | room_1    | {"rt.ty": "5678"} |

  # --------------------- attribute type  ------------------------------------

  @attribute_type_replace @BUG_1212 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attributes type
    Given  a definition of headers
      | parameter          | value                  |
      | Fiware-Service     | attribute_type_replace |
      | Fiware-ServicePath | /test                  |
      | Content-Type       | application/json       |
    And create "1" entities with "3" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 56          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter       | value             |
      | attributes_name | pressure          |
      | attributes_type | <attributes_type> |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_type |
      | 34              |
      | 34.4E-34        |
      | temp.34         |
      | temp_34         |
      | temp-34         |
      | TEMP34          |
      | house_flat      |
      | house.flat      |
      | house-flat      |
      | house@flat      |
      | habitación      |
      | españa          |
      | barça           |
      | random=10       |
      | random=100      |
      | random=1000     |
      | random=10000    |
      | random=100000   |

  @attribute_type_replace_forbidden @BUG_1212 @BUG_1260 @skip
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with forbidden attributes type
    Given  a definition of headers
      | parameter          | value                             |
      | Fiware-Service     | test_replace_attribute_type_error |
      | Fiware-ServicePath | /test                             |
      | Content-Type       | application/json                  |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>"
      | parameter       | value             |
      | attributes_name | pressure          |
      | attributes_type | <attributes_type> |
    Then verify that receive an "Bad Request" http code
    And verify several error responses
      | parameter   | value                                |
      | error       | BadRequest                           |
      | description | Invalid characters in attribute type |
    Examples:
      | entity_id | attributes_type |
      | room_2    | house<flat>     |
      | room_3    | house=flat      |
      | room_4    | house"flat"     |
      | room_5    | house'flat'     |
      | room_6    | house;flat      |
      | room_8    | house(flat)     |

  @attribute_type_replace_wrong
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with wrong attributes type
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_replace_attribute_type_error_ii |
      | Fiware-ServicePath | /test                                |
      | Content-Type       | application/json                     |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter       | value             |
      | attributes_name | "pressure"        |
      | attributes_type | <attributes_type> |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | ParseError                           |
      | description | Errors found in incoming JSON buffer |
    Examples:
      | entity_id | attributes_type |
      | room1     | rewrewr         |
      | room2     | SDFSDFSDF       |

  @attribute_type_replace_invalid @BUG_1212 @skip
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with invalid attributes type
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_update_attribute_type_error_iii |
      | Fiware-ServicePath | /test                                |
      | Content-Type       | application/json                     |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter       | value             |
      | attributes_name | "pressure"        |
      | attributes_type | <attributes_type> |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | ParseError                           |
      | description | Errors found in incoming JSON buffer |
    Examples:
      | entity_id | attributes_type |
      | room3     | false           |
      | room4     | true            |
      | room5     | 34              |
      | room6     | {"a":34}        |
      | room7     | ["34", "a", 45] |

  # --------------------- attribute metadata name  ------------------------------------

  @attribute_metadata_name_replace_without_meta_type @BUG_1217 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute metadata name and with attribute type but without attribute metadata type in replace request
    Given  a definition of headers
      | parameter          | value                                                  |
      | Fiware-Service     | test_attribute_metadata_name_replace_without_meta_type |
      | Fiware-ServicePath | /test                                                  |
      | Content-Type       | application/json                                       |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter       | value                  |
      | attributes_name | pressure               |
      | attributes_type | bar                    |
      | metadatas_name  | <attributes_meta_name> |
      | metadatas_value | 5678                   |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_meta_name |
      | 34                   |
      | 34.4E-34             |
      | temp.34              |
      | temp_34              |
      | temp-34              |
      | TEMP34               |
      | house_flat           |
      | house.flat           |
      | house-flat           |
      | house@flat           |
      | habitación           |
      | españa               |
      | barça                |
      | random=10            |
      | random=100           |
      | random=1000          |
      | random=10000         |
      | random=100000        |

  @attribute_metadata_name_replace_without_meta_type @BUG_1217 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute metadata name and without attribute metadata type nor attribute type in replace request
    Given  a definition of headers
      | parameter          | value                                                  |
      | Fiware-Service     | test_attribute_metadata_name_replace_without_meta_type |
      | Fiware-ServicePath | /test                                                  |
      | Content-Type       | application/json                                       |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter       | value                  |
      | attributes_name | pressure               |
      | metadatas_name  | <attributes_meta_name> |
      | metadatas_value | 5678                   |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_meta_name |
      | 34                   |
      | 34.4E-34             |
      | temp.34              |
      | temp_34              |
      | temp-34              |
      | TEMP34               |
      | house_flat           |
      | house.flat           |
      | house-flat           |
      | house@flat           |
      | habitación           |
      | españa               |
      | barça                |
      | random=10            |
      | random=100           |
      | random=1000          |
      | random=10000         |
      | random=100000        |

  @attribute_metadata_name_replace_with_meta_type @BUG_1217 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute metadata name without attribute type but with attribute metadata type in replace request
    Given  a definition of headers
      | parameter          | value                                               |
      | Fiware-Service     | test_attribute_metadata_name_replace_with_meta_type |
      | Fiware-ServicePath | /test                                               |
      | Content-Type       | application/json                                    |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter       | value                  |
      | attributes_name | pressure               |
      | metadatas_name  | <attributes_meta_name> |
      | metadatas_value | 5678                   |
      | metadatas_type  | metatype               |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_meta_name |
      | 34                   |
      | 34.4E-34             |
      | temp.34              |
      | temp_34              |
      | temp-34              |
      | TEMP34               |
      | house_flat           |
      | house.flat           |
      | house-flat           |
      | house@flat           |
      | habitación           |
      | españa               |
      | barça                |
      | random=10            |
      | random=100           |
      | random=1000          |
      | random=10000         |
      | random=100000        |

  @attribute_metadata_name_replace_forbidden_without_meta_type @BUG_1220 @skip
  Scenario Outline:  try to replace attribute by entity ID using NGSI v2 with forbidden attribute metadata name without attribute metadata type
    Given  a definition of headers
      | parameter          | value                                      |
      | Fiware-Service     | test_attribute_metadata_name_replace_error |
      | Fiware-ServicePath | /test                                      |
      | Content-Type       | application/json                           |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>"
      | parameter       | value                  |
      | attributes_name | pressure               |
      | metadatas_name  | <attributes_meta_name> |
      | metadatas_value | 5678                   |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | BadRequest                           |
      | description | Invalid characters in attribute name |
    Examples:
      | entity_id | attributes_meta_name |
      | room_2    | house<flat>          |
      | room_3    | house=flat           |
      | room_4    | house"flat"          |
      | room_5    | house'flat'          |
      | room_6    | house;flat           |
      | room_8    | house(flat)          |

  @attribute_metadata_name_replace_forbidden_with_meta_type @BUG_1220 @skip
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with forbidden attribute metadata name with attribute metadata type
    Given  a definition of headers
      | parameter          | value                                      |
      | Fiware-Service     | test_attribute_metadata_name_replace_error |
      | Fiware-ServicePath | /test                                      |
      | Content-Type       | application/json                           |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>"
      | parameter       | value                  |
      | attributes_name | pressure               |
      | metadatas_name  | <attributes_meta_name> |
      | metadatas_value | 5678                   |
      | metadatas_type  | metatype               |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | BadRequest                           |
      | description | Invalid characters in attribute name |
    Examples:
      | entity_id | attributes_meta_name |
      | room_2    | house<flat>          |
      | room_3    | house=flat           |
      | room_4    | house"flat"          |
      | room_5    | house'flat'          |
      | room_6    | house;flat           |
      | room_8    | house(flat)          |

  @attribute_metadata_name_replace_error @BUG_1220 @skip
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with wrong attribute metadata name without attribute metadata type
    Given  a definition of headers
      | parameter          | value                                      |
      | Fiware-Service     | test_attribute_metadata_name_replace_error |
      | Fiware-ServicePath | /test                                      |
      | Content-Type       | application/json                           |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
    And verify that receive several "Created" http code
    When replace attributes by ID "room" in raw mode
      | parameter       | value                  |
      | attributes_name | "pressure"             |
      | metadatas_name  | <attributes_meta_name> |
      | metadatas_value | "5678"                 |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | BadRequest                           |
      | description | Errors found in incoming JSON buffer |
    Examples:
      | attributes_meta_name |
      | rewrewr              |
      | SDFSDFSDF            |
      | false                |
      | true                 |
      | 34                   |
      | {"a":34}             |
      | ["34", "a", 45]      |
      | null                 |

  @attribute_metadata_name_replace_error @BUG_1220 @skip
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with wrong attribute metadata name with attribute metadata type
    Given  a definition of headers
      | parameter          | value                                      |
      | Fiware-Service     | test_attribute_metadata_name_replace_error |
      | Fiware-ServicePath | /test                                      |
      | Content-Type       | application/json                           |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
    And verify that receive several "Created" http code
    When replace attributes by ID "room" in raw mode
      | parameter       | value                  |
      | attributes_name | "pressure"             |
      | metadatas_name  | <attributes_meta_name> |
      | metadatas_value | "5678"                 |
      | metadatas_type  | "metatype"             |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | BadRequest                           |
      | description | Errors found in incoming JSON buffer |
    Examples:
      | attributes_meta_name |
      | rewrewr              |
      | SDFSDFSDF            |
      | false                |
      | true                 |
      | 34                   |
      | {"a":34}             |
      | ["34", "a", 45]      |
      | null                 |

  @attribute_metadata_name_replace_empty @BUG_1220 @skip
  Scenario:  try to replace attributes by entity ID using NGSI v2 with empty attribute metadata name without attribute metadata type
    Given  a definition of headers
      | parameter          | value                                      |
      | Fiware-Service     | test_attribute_metadata_name_replace_empty |
      | Fiware-ServicePath | /test                                      |
      | Content-Type       | application/json                           |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter       | value    |
      | attributes_name | pressure |
      | metadatas_name  |          |
      | metadatas_value | 5678     |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                          |
      | error       | BadRequest                     |
      | description | no 'name' for ContextAttribute |

  @attribute_metadata_name_replace_empty @BUG_1220 @skip
  Scenario:  try to replace attributes by entity ID using NGSI v2 with empty attribute metadata name with attribute metadata type
    Given  a definition of headers
      | parameter          | value                                      |
      | Fiware-Service     | test_attribute_metadata_name_replace_empty |
      | Fiware-ServicePath | /test                                      |
      | Content-Type       | application/json                           |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter       | value    |
      | attributes_name | pressure |
      | metadatas_name  |          |
      | metadatas_value | 5678     |
      | metadatas_type  | celcius  |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                          |
      | error       | BadRequest                     |
      | description | no 'name' for ContextAttribute |

  # --------------------- attribute metadata value  ------------------------------------

  @attribute_metadata_value_replace @BUG_1220 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute metadata values without attribute metadata type
    Given  a definition of headers
      | parameter          | value                            |
      | Fiware-Service     | attribute_metadata_value_replace |
      | Fiware-ServicePath | /test                            |
      | Content-Type       | application/json                 |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter       | value                   |
      | attributes_name | pressure                |
      | metadatas_name  | very_cold               |
      | metadatas_value | <attributes_meta_value> |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_meta_value |
      | 34                    |
      | 34.4E-34              |
      | temp.34               |
      | temp_34               |
      | temp-34               |
      | TEMP34                |
      | house_flat            |
      | house.flat            |
      | house-flat            |
      | house@flat            |
      | habitación            |
      | españa                |
      | barça                 |
      | random=10             |
      | random=100            |
      | random=1000           |
      | random=10000          |
      | random=100000         |

  @attribute_metadata_value_replace @BUG_1232 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute metadata values with attribute metadata type
    Given  a definition of headers
      | parameter          | value                            |
      | Fiware-Service     | attribute_metadata_value_replace |
      | Fiware-ServicePath | /test                            |
      | Content-Type       | application/json                 |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter       | value                   |
      | attributes_name | pressure                |
      | metadatas_name  | very_cold               |
      | metadatas_type  | alarm                   |
      | metadatas_value | <attributes_meta_value> |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_meta_value |
      | 34                    |
      | 34.4E-34              |
      | temp.34               |
      | temp_34               |
      | temp-34               |
      | TEMP34                |
      | house_flat            |
      | house.flat            |
      | house-flat            |
      | house@flat            |
      | habitación            |
      | españa                |
      | barça                 |
      | random=10             |
      | random=100            |
      | random=1000           |
      | random=10000          |
      | random=100000         |

  # compound metadatas values are pending
  @attribute_metadata_value_replace_special_without_meta_type @BUG_1220 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with special metadata attribute values (compound, vector, boolean, etc) and without attribute metadata type
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_replace_attribute_value_special |
      | Fiware-ServicePath | /test                                |
      | Content-Type       | application/json                     |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 45          |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter       | value                   |
      | attributes_name | "pressure"              |
      | metadatas_name  | "very_cold"             |
      | metadatas_value | <attributes_meta_value> |
    Then verify that receive an "No Content" http code
    Examples:
      | entity_id | attributes_meta_value |
      | room1     | true                  |
      | room2     | false                 |
      | room3     | 34                    |
      | room4     | -34                   |
      | room5     | 5.00002               |
      | room6     | -5.00002              |

  @attribute_metadata_value_replace_special_with_meta_type @BUG_1220 @skip
  Scenario Outline:  update an attribute by entity ID using NGSI v2 with special metadata attribute values (compound, vector, boolean, etc) and with attribute metadata type
    Given  a definition of headers
      | parameter          | value                                |
      | Fiware-Service     | test_replace_attribute_value_special |
      | Fiware-ServicePath | /test                                |
      | Content-Type       | application/json                     |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 45          |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter       | value                   |
      | attributes_name | "pressure"              |
      | metadatas_name  | "very_cold"             |
      | metadatas_value | <attributes_meta_value> |
      | metadatas_type  | "alarm"                 |
    Then verify that receive an "No Content" http code
    Examples:
      | entity_id | attributes_meta_value |
      | room1     | true                  |
      | room2     | false                 |
      | room3     | 34                    |
      | room4     | -34                   |
      | room5     | 5.00002               |
      | room6     | -5.00002              |

  @attribute_metadata_value_replace_forbidden @BUG_1216 @skip
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with forbidden attributes metadata values without attribute metadata type
    Given  a definition of headers
      | parameter          | value                                        |
      | Fiware-Service     | attribute_metadata_value_replace_error_wo_mt |
      | Fiware-ServicePath | /test                                        |
      | Content-Type       | application/json                             |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 45          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>"
      | parameter       | value                   |
      | attributes_name | pressure                |
      | metadatas_name  | very_cold               |
      | metadatas_value | <attributes_meta_value> |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | BadRequest                           |
      | description | Invalid characters in attribute type |
    Examples:
      | entity_id | attributes_meta_value |
      | room_2    | house<flat>           |
      | room_3    | house=flat            |
      | room_4    | house"flat"           |
      | room_5    | house'flat'           |
      | room_6    | house;flat            |
      | room_8    | house(flat)           |

  @attribute_metadata_value_replace_forbidden @BUG_1216 @skip
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with forbidden attributes metadata values with attribute metadata type
    Given  a definition of headers
      | parameter          | value                                       |
      | Fiware-Service     | attribute_metadata_value_replace_error_w_mt |
      | Fiware-ServicePath | /test                                       |
      | Content-Type       | application/json                            |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 45          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>"
      | parameter       | value                   |
      | attributes_name | pressure                |
      | metadatas_name  | very_cold               |
      | metadatas_value | <attributes_meta_value> |
      | metadatas_type  | bar                     |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | BadRequest                           |
      | description | Invalid characters in attribute type |
    Examples:
      | entity_id | attributes_meta_value |
      | room_2    | house<flat>           |
      | room_3    | house=flat            |
      | room_4    | house"flat"           |
      | room_5    | house'flat'           |
      | room_6    | house;flat            |
      | room_8    | house(flat)           |

  @attribute_metadata_value_update_error
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with wrong attributes metadata values without attribute metadata type
    Given  a definition of headers
      | parameter          | value                                        |
      | Fiware-Service     | attribute_metadata_value_replace_error_wo_mt |
      | Fiware-ServicePath | /test                                        |
      | Content-Type       | application/json                             |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 45          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter       | value                   |
      | attributes_name | pressure                |
      | metadatas_name  | very_cold               |
      | metadatas_value | <attributes_meta_value> |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | ParseError                           |
      | description | Errors found in incoming JSON buffer |
    Examples:
      | entity_id | attributes_meta_value |
      | room_1    | rwerwer               |
      | room_2    | True                  |
      | room_3    | TRUE                  |
      | room_4    | False                 |
      | room_5    | FALSE                 |
      | room_6    | 34r                   |
      | room_7    | 5_34                  |
      | room_8    | ["a", "b"             |
      | room_9    | ["a" "b"]             |
      | room_10   | "a", "b"]             |
      | room_11   | ["a" "b"}             |
      | room_12   | {"a": "b"             |
      | room_13   | {"a" "b"}             |
      | room_14   | "a": "b"}             |

  @attribute_metadata_value_replace_error
  Scenario Outline:  try to replace attributes by entity ID using NGSI v2 with wrong attributes metadata values with attribute metadata type
    Given  a definition of headers
      | parameter          | value                                  |
      | Fiware-Service     | attribute_metadata_value_replace_error |
      | Fiware-ServicePath | /test                                  |
      | Content-Type       | application/json                       |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | <entity_id> |
      | attributes_name  | temperature |
      | attributes_value | 45          |
    And verify that receive several "Created" http code
    When replace attributes by ID "<entity_id>" in raw mode
      | parameter       | value                   |
      | attributes_name | pressure                |
      | metadatas_name  | very_cold               |
      | metadatas_value | <attributes_meta_value> |
      | metadatas_type  | celcius                 |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | ParseError                           |
      | description | Errors found in incoming JSON buffer |
    Examples:
      | entity_id | attributes_meta_value |
      | room_1    | rwerwer               |
      | room_2    | True                  |
      | room_3    | TRUE                  |
      | room_4    | False                 |
      | room_5    | FALSE                 |
      | room_6    | 34r                   |
      | room_7    | 5_34                  |
      | room_8    | ["a", "b"             |
      | room_9    | ["a" "b"]             |
      | room_10   | "a", "b"]             |
      | room_11   | ["a" "b"}             |
      | room_12   | {"a": "b"             |
      | room_13   | {"a" "b"}             |
      | room_14   | "a": "b"}             |

    # --------------------- attribute metadata type  ------------------------------------

  @attribute_metadata_type_replace_wo_type @BUG_1216 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute metadata type without attribute type
    Given  a definition of headers
      | parameter          | value                           |
      | Fiware-Service     | attribute_metadata_type_replace |
      | Fiware-ServicePath | /test                           |
      | Content-Type       | application/json                |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter       | value                  |
      | attributes_name | pressure               |
      | metadatas_name  | very_cold              |
      | metadatas_value | 678                    |
      | metadatas_type  | <attributes_meta_type> |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_meta_type |
      | 34                   |
      | 34.4E-34             |
      | temp.34              |
      | temp_34              |
      | temp-34              |
      | TEMP34               |
      | house_flat           |
      | house.flat           |
      | house-flat           |
      | house@flat           |
      | habitación           |
      | españa               |
      | barça                |
      | random=10            |
      | random=100           |
      | random=1000          |
      | random=10000         |
      | random=100000        |

  @attribute_metadata_type_replace_wo_type @BUG_1216 @skip
  Scenario Outline:  replace attributes by entity ID using NGSI v2 with several attribute metadata type without attribute type
    Given  a definition of headers
      | parameter          | value                           |
      | Fiware-Service     | attribute_metadata_type_replace |
      | Fiware-ServicePath | /test                           |
      | Content-Type       | application/json                |
    And create "1" entities with "1" attributes
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room        |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | attributes_type  | celcius     |
      | metadatas_number | 2           |
      | metadatas_name   | very_hot    |
      | metadatas_type   | alarm       |
      | metadatas_value  | hot         |
    And verify that receive several "Created" http code
    When replace attributes by ID "room"
      | parameter       | value                  |
      | attributes_name | pressure               |
      | attributes_type | bar                    |
      | metadatas_name  | very_cold              |
      | metadatas_value | 678                    |
      | metadatas_type  | <attributes_meta_type> |
    Then verify that receive an "No Content" http code
    And verify that an entity is updated in mongo
    Examples:
      | attributes_meta_type |
      | 34                   |
      | 34.4E-34             |
      | temp.34              |
      | temp_34              |
      | temp-34              |
      | TEMP34               |
      | house_flat           |
      | house.flat           |
      | house-flat           |
      | house@flat           |
      | habitación           |
      | españa               |
      | barça                |
      | random=10            |
      | random=100           |
      | random=1000          |
      | random=10000         |
      | random=100000        |

  @attribute_metadata_type_update_error @BUG_1232 @skip
  Scenario Outline:  try to update an attribute by entity ID using NGSI v2 with forbidden attribute metadata type
    Given  a definition of headers
      | parameter          | value                          |
      | Fiware-Service     | attribute_metadata_type_update |
      | Fiware-ServicePath | /test                          |
      | Content-Type       | application/json               |
    When update an attribute by ID "<entity_id>" if it exists
      | parameter       | value                  |
      | attributes_name | temperature            |
      | metadatas_name  | very_hot_0             |
      | metadatas_value | 678                    |
      | metadatas_type  | <attributes_meta_type> |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                               |
      | error       | BadRequest                          |
      | description | Invalid characters in metadata type |
    And verify that entities are not stored in mongo
    Examples:
      | entity_id | attributes_meta_type |
      | room_2    | house<flat>          |
      | room_3    | house=flat           |
      | room_4    | house"flat"          |
      | room_5    | house'flat'          |
      | room_6    | house;flat           |
      | room_8    | house(flat)          |

  @attribute_metadata_type_update_wrong
  Scenario Outline:  try to update an attribute by entity ID using NGSI v2 with wrong metadata attribute types
    Given  a definition of headers
      | parameter          | value                            |
      | Fiware-Service     | test_update_attribute_type_error |
      | Fiware-ServicePath | /test                            |
      | Content-Type       | application/json                 |
    When update an attribute by ID "<entity_id>" if it exists in raw mode
      | parameter       | value                  |
      | attributes_name | "temperature"          |
      | metadatas_name  | "very_cold"            |
      | metadatas_type  | <attributes_meta_type> |
      | metadatas_value | "hot"                  |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | ParseError                           |
      | description | Errors found in incoming JSON buffer |
    Examples:
      | entity_id | attributes_meta_type |
      | room1     | rewrewr              |
      | room2     | SDFSDFSDF            |

  @attribute_metadata_type_update_wrong @BUG_1232 @skip
  Scenario Outline:  try to update an attribute by entity ID using NGSI v2 with wrong metadata attribute types
    Given  a definition of headers
      | parameter          | value                            |
      | Fiware-Service     | test_update_attribute_type_error |
      | Fiware-ServicePath | /test                            |
      | Content-Type       | application/json                 |
    When update an attribute by ID "<entity_id>" if it exists in raw mode
      | parameter       | value                  |
      | attributes_name | "temperature"          |
      | metadatas_name  | "very_cold"            |
      | metadatas_type  | <attributes_meta_type> |
      | metadatas_value | "hot"                  |
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                         |
      | error       | ParseError                                    |
      | description | invalid JSON type for attribute metadata type |
    Examples:
      | entity_id | attributes_meta_type |
      | room3     | false                |
      | room4     | true                 |
      | room5     | 34                   |
      | room6     | {"a":34}             |
      | room7     | ["34", "a", 45]      |
