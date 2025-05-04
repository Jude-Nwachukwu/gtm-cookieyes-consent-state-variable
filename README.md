# CookieYes Consent State – GTM Custom Variable Template (Unofficial)

This Google Tag Manager (GTM) custom variable template retrieves user consent states from the [CookieYes](https://www.cookieyes.com/) Consent Management Platform (CMP). It is especially useful when:

- CookieYes is installed **outside GTM** (i.e., directly in the site code).
- You want to support **Basic or Advanced Consent Mode**.
- You need to create **exception triggers** based on specific consent categories.

> Developed by **Jude** for [DumbData](https://dumbdata.co/)

---

## 🛠️ How to Use This Template


## 📦 Import the Template

1. Open Google Tag Manager.
2. Go to **Templates** → **Variable Templates**.
3. Click the **New** button and select **Import**.
4. Upload the `.tpl` file for this template.

## 🎛️ Configuration Options

### 1. **Select Consent State Check Type**

Use the dropdown **“Select Consent State Check Type”** to determine how the variable works:

- **All Consent State Check** – Returns an object containing consent states for all major categories.
- **Specific Consent State** – Returns only the state of a single selected category.

### 2. **Select Consent Category**

(Shown only when **Specific Consent State** is selected)

Choose from the following categories in the **“Select Consent Category”** radio field:

- Performance  
- Necessary  
- Advertisement  
- Functional  
- Analytics  

### 3. **Enable Optional Output Transformation**

Enable this checkbox to customize the output values returned by the variable.

#### Sub-options include:

- **Transform "Yes"**: Convert `yes` to:
  - `granted`
  - `accept`
  - `true`

- **Transform "No"**: Convert `no` to:
  - `denied`
  - `deny`
  - `false`

- **Also transform "undefined" to "no"**: Ensures categories without explicit values default to `"no"`.

## 🔍 Behavior Details

- The template reads from the `cookieyes-consent` cookie if available.
- If not found, it will fall back to `cookieyes._ckyConsentStore`.
- If a consent category is **missing** or **has no value**, it is treated as `"no"`—**except for `necessary`**, which defaults to `"yes"` if present but empty.
- Values can be transformed to suit your tag logic needs via the optional configuration.

## 🧰 Use Cases

- Enabling or blocking tags based on specific user consent signals
- Using CookieYes with **Basic or Advanced Consent Mode** in GTM
- Creating exception triggers in GTM based on consent categories

---

> 📦 This template bridges GTM with CookieYes consent signals, giving you control over tag behavior even when CookieYes is not deployed through GTM.
