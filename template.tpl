___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "CookieYes Consent State",
  "description": "Use with the CookieYes CMP to identify the individual website user\u0027s consent state and configure when tags should execute.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "cookieYesConsentStateCheckType",
    "displayName": "Select Consent State Check Type",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "cookieYesAllConsentState",
        "displayValue": "All Consent State Check"
      },
      {
        "value": "cookieYesSpecificConsentState",
        "displayValue": "Specific Consent State"
      }
    ],
    "simpleValueType": true,
    "help": "Select the type of consent state check you want to perform—either a specific consent category or all consent categories, based on CookieYes."
  },
  {
    "type": "RADIO",
    "name": "cookieYesConsentCategoryCheck",
    "displayName": "Select Consent Category",
    "radioItems": [
      {
        "value": "cookieYesPerformance",
        "displayValue": "Performance"
      },
      {
        "value": "cookieYesNecessary",
        "displayValue": "Necessary"
      },
      {
        "value": "cookieYesAdvertisement",
        "displayValue": "Advertisement"
      },
      {
        "value": "cookieYesFunctional",
        "displayValue": "Functional"
      },
      {
        "value": "cookieYesAnalytics",
        "displayValue": "Analytics"
      }
    ],
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "cookieYesConsentStateCheckType",
        "paramValue": "cookieYesSpecificConsentState",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "cookieYesEnableOptionalConfig",
    "checkboxText": "Enable Optional Output Transformation",
    "simpleValueType": true
  },
  {
    "type": "GROUP",
    "name": "cookieYesOptionalConfig",
    "displayName": "CookieYes Consent State Value Transformation",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SELECT",
        "name": "cookieYesTrue",
        "displayName": "Transform \"Yes\"",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "cookieYesYesGranted",
            "displayValue": "granted"
          },
          {
            "value": "cookieYesYesAccept",
            "displayValue": "accept"
          },
          {
            "value": "cookieYesYesTrue",
            "displayValue": "true"
          }
        ],
        "simpleValueType": true
      },
      {
        "type": "SELECT",
        "name": "cookieYesFalse",
        "displayName": "Transform \"No\"",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "cookieYesNoDenied",
            "displayValue": "denied"
          },
          {
            "value": "cookieYesNoDeny",
            "displayValue": "deny"
          },
          {
            "value": "cookieYesNoFalse",
            "displayValue": "false"
          }
        ],
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "cookieYesUndefined",
        "checkboxText": "Also transform \"undefined\" to \"no\"",
        "simpleValueType": true
      }
    ],
    "enablingConditions": [
      {
        "paramName": "cookieYesEnableOptionalConfig",
        "paramValue": true,
        "type": "EQUALS"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const copyFromWindow = require('copyFromWindow');
const getCookieValues = require('getCookieValues');
const getType = require('getType');
const makeString = require('makeString');
const decodeUriComponent = require('decodeUriComponent');

const checkType = data.cookieYesConsentStateCheckType;
const categoryKey = data.cookieYesConsentCategoryCheck;
const enableTransform = data.cookieYesEnableOptionalConfig;
const transformYes = data.cookieYesTrue;
const transformNo = data.cookieYesFalse;
const transformUndefined = data.cookieYesUndefined;

// Consent categories to check
const consentCategories = ['necessary', 'functional', 'performance', 'advertisement', 'analytics'];

function getCategoryKey(rawKey) {
  return makeString(rawKey).replace('cookieYes', '').toLowerCase();
}

function transformValue(val) {
  if (!enableTransform) return val;

  if (val === 'yes') {
    if (transformYes === 'cookieYesYesGranted') return 'granted';
    if (transformYes === 'cookieYesYesAccept') return 'accept';
    if (transformYes === 'cookieYesYesTrue') return 'true';
  }

  if (val === 'no') {
    if (transformNo === 'cookieYesNoDenied') return 'denied';
    if (transformNo === 'cookieYesNoDeny') return 'deny';
    if (transformNo === 'cookieYesNoFalse') return 'false';
  }

  if (getType(val) === 'undefined' && transformUndefined) {
    return 'no';
  }

  return val;
}

function getConsentFromCookie() {
  const raw = getCookieValues('cookieyes-consent');
  if (!raw || getType(raw[0]) !== 'string') return undefined;

  const decoded = decodeUriComponent(raw[0]);
  const parts = decoded.split(',');
  const consentMap = {};

  for (let i = 0; i < parts.length; i++) {
    const segment = parts[i].split(':');
    if (segment.length === 2) {
      const key = segment[0];
      const value = segment[1];
      // Treat missing values as "no" except for "necessary" which defaults to "yes" if empty
      if (value === 'yes') {
        consentMap[key] = 'yes';
      } else if (key === 'necessary' && value === '') {
        consentMap[key] = 'yes';
      } else {
        consentMap[key] = 'no';
      }
    }
  }

  // Ensure all categories are present
  consentCategories.forEach(function (key) {
    if (!consentMap.hasOwnProperty(key)) {
      consentMap[key] = 'no';
    }
  });

  return consentMap;
}

function getConsentFromWindowStore() {
  const store = copyFromWindow('cookieyes._ckyConsentStore');
  if (getType(store) !== 'object' || typeof store.get !== 'function') return undefined;

  const result = {};
  consentCategories.forEach(function (key) {
    const value = store.get(key);
    result[key] = value === 'yes' ? 'yes' : 'no';
  });

  return result;
}

function getConsentState() {
  let consent = getConsentFromCookie();
  if (!consent) {
    consent = getConsentFromWindowStore();
  }
  return consent;
}

const consentData = getConsentState();
if (!consentData) return undefined;

if (checkType === 'cookieYesAllConsentState') {
  const result = {};
  consentCategories.forEach(function (key) {
    const val = consentData.hasOwnProperty(key) ? consentData[key] : 'no';
    result[key] = transformValue(val);
  });
  return result;

} else if (checkType === 'cookieYesSpecificConsentState') {
  const category = getCategoryKey(categoryKey);

  if (!category || consentCategories.indexOf(category) === -1) return undefined;

  const val = consentData.hasOwnProperty(category) ? consentData[category] : 'no';
  return transformValue(val);
}

return undefined;


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "cookieyes._ckyConsentStore"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "cookieyes-consent"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 5/5/2025, 9:20:06 AM


