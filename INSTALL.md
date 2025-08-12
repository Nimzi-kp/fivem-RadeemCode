# KP-Radeem Installation Guide

This guide provides detailed instructions for installing and configuring the KP-Radeem redemption code system on your FiveM server.

## Prerequisites

Before installing KP-Radeem, ensure you have the following dependencies installed and configured on your server:

- [es_extended](https://github.com/esx-framework/esx-legacy) (ESX Framework)
- [ox_lib](https://github.com/overextended/ox_lib) (Notification system)
- [oxmysql](https://github.com/overextended/oxmysql) (MySQL database wrapper)
- [ox_inventory](https://github.com/overextended/ox_inventory) (Inventory system)
- [cd_garage](https://github.com/dsheedes/cd_garage) (Garage system)
- [codem-banking](https://github.com/Codesign-Development/codem-banking) (Banking system)
- [okok-chat](https://okok.tebex.io/package/4724993) (Chat system)

## Step 1: Download and Extract

1. Download the latest release of KP-Radeem
2. Extract the files to your server's resources folder
3. Ensure the folder is named `kp-radeem`

## Step 2: Configure Discord Webhooks

1. Open `config/config.lua` in a text editor
2. Locate the Webhooks section:
   ```lua
   Config.Webhooks = {
       Created = "",  -- Webhook for code creation logs
       Claimed = "",  -- Webhook for code redemption logs
       Deleted = ""   -- Webhook for code deletion logs
   }
   ```
3. Create three webhooks in your Discord server:
   - One for code creation logs
   - One for code redemption logs
   - One for code deletion logs
4. Copy each webhook URL and paste it into the corresponding field in the config file

## Step 3: Configure Permissions

1. In the same `config/config.lua` file, locate the AdminGroups section:
   ```lua
   Config.AdminGroups = {
       ["admin"] = true,
       ["superadmin"] = true,
       ["mod"] = true
   }
   ```
2. Modify this list to include the admin groups on your server that should have access to the redemption code system
3. Add or remove groups as needed

## Step 4: Customize Commands (Optional)

If you want to change the default commands:

1. Locate the Commands section in `config/config.lua`:
   ```lua
   Config.Commands = {
       Admin = "createradeem",  -- Command for admins to open the creation UI
       User = "redeem"          -- Command for users to redeem codes
   }
   ```
2. Change the command names as desired

## Step 5: Add to server.cfg

1. Open your server's `server.cfg` file
2. Add the following line:
   ```
   ensure kp-radeem
   ```
3. Make sure it's placed after all the dependencies

## Step 6: Start/Restart Your Server

1. Save all changes to configuration files
2. Start or restart your FiveM server
3. Check the server console for any error messages
4. Verify that the resource starts successfully

## Step 7: Verify Installation

1. Connect to your server as an admin
2. Use the `/createradeem` command (or your custom command if changed)
3. The admin UI should open
4. Create a test redemption code
5. Use the `/redeem [code]` command to test redeeming the code
6. Check your Discord webhooks to ensure logs are being sent correctly

## Troubleshooting

### Database Issues

If you encounter database-related errors:

1. Ensure oxmysql is properly installed and running
2. Check that your database connection is configured correctly
3. Manually verify that the KP-Radeem tables were created:
   - `kp_redeem_codes`
   - `kp_redeem_rewards`
   - `kp_redeem_history`

### Permission Issues

If admins cannot access the UI:

1. Verify that the admin's group is correctly set in the ESX database
2. Ensure the admin group is listed in the `Config.AdminGroups` table
3. Check server logs for any permission-related errors

### UI Not Showing

If the UI doesn't appear when using the command:

1. Check the browser console (F8) for any JavaScript errors
2. Ensure all UI files are in the correct locations
3. Verify that the NUI callbacks are registered correctly

### Webhook Issues

If logs are not being sent to Discord:

1. Verify that the webhook URLs are correct
2. Ensure your server has internet access to reach Discord
3. Check for any rate limiting issues with Discord webhooks

## Support

For additional support:

1. Check the README.md file for basic usage instructions
2. Contact the developer through the FiveM forums or Discord
3. Report any bugs or issues with detailed information about your server setup