# KP-Radeem

A comprehensive redemption code system for FiveM servers. This script allows administrators to create redemption codes that players can use to receive various rewards including money, items, and vehicles.

## Features

- **Admin UI**: Intuitive tablet-style interface for creating and managing redemption codes
- **Multiple Reward Types**: Add money, items, or vehicles to redemption codes
- **Usage Limits**: Set how many times each code can be redeemed
- **Detailed Logging**: Comprehensive webhook logging for code creation, redemption, and deletion
- **Custom Vehicle Plates**: Option to set custom license plates for vehicle rewards
- **Code Management**: View all active codes, their details, and delete codes when needed

## Dependencies

- [es_extended](https://github.com/esx-framework/esx-legacy) - ESX Framework
- [ox_lib](https://github.com/overextended/ox_lib) - Notification system
- [oxmysql](https://github.com/overextended/oxmysql) - MySQL database wrapper
- [ox_inventory](https://github.com/overextended/ox_inventory) - Inventory system
- [cd_garage](https://github.com/dsheedes/cd_garage) - Garage system
- [codem-banking](https://github.com/Codesign-Development/codem-banking) - Banking system
- [okok-chat](https://okok.tebex.io/package/4724993) - Chat system

## Installation

1. **Download the Resource**:
   - Download the latest release or clone this repository.

2. **Place in Resources Folder**:
   - Extract the files to your server's resources folder.
   - Ensure the folder is named `kp-radeem`.

3. **Database Setup**:
   - The necessary database tables will be created automatically when the resource starts.

4. **Configure Webhooks**:
   - Open `config/config.lua` and set your Discord webhook URLs for logging.

5. **Add to server.cfg**:
   ```
   ensure kp-radeem
   ```

## Usage

### Admin Commands

- `/createradeem` - Opens the admin UI for creating and managing redemption codes

### Player Commands

- `/redeem [code]` - Redeems a code to receive rewards

### Creating a Redemption Code

1. Use the `/createradeem` command to open the admin UI
2. Select the "Create New" tab
3. Click "Add Product" to add rewards to the code
4. Choose the reward type (Money, Item, or Vehicle)
5. Fill in the required details for the reward
6. Add as many rewards as needed
7. Enter a description for the code (purpose, event, etc.)
8. Set the usage limit (how many times the code can be redeemed)
9. Click "Generate Code" to create the redemption code

### Managing Existing Codes

1. Use the `/createradeem` command to open the admin UI
2. Select the "Existing Codes" tab
3. View all active redemption codes
4. Click "Details" to see complete information about a code
5. Click "Delete" to remove a code (requires deletion reason)

### Redeeming a Code

Players can redeem codes using the command:
```
/redeem KP12345678
```

## Configuration

The main configuration file is located at `config/config.lua`. Here you can modify:

- Code prefix and length
- UI size
- Webhook URLs for logging
- Admin permission groups
- Command names

## Logging

KP-Radeem includes comprehensive logging via Discord webhooks:

- **Creation Logs**: Records who created a code, what rewards it contains, and other details
- **Redemption Logs**: Records who redeemed a code, what rewards they received, and when
- **Deletion Logs**: Records who deleted a code, why it was deleted, and what rewards it contained

## License

This resource is protected under copyright law. Unauthorized distribution, modification, or resale is prohibited.

## Support

For support, please contact the developer through the FiveM forums or Discord.