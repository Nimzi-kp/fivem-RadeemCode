const app = new Vue({
    el: '#app',
    data: {
        showUI: false,
        activeTab: 'create',
        
        // New code form data
        newCode: {
            rewards: [],
            description: '',
            usageLimit: 1
        },
        
        // New reward form data
        newReward: {
            type: '',
            subtype: 'cash',
            name: '',
            model: '',
            amount: 1,
            hasCustomPlate: false,
            plate: '',
            customName: '',
            customModel: ''
        },
        
        // Lists for dropdowns
        itemList: [],
        vehicleList: [],
        
        // Existing codes
        codes: [],
        
        // Selected code for details/delete
        selectedCode: null,
        deleteReason: '',
        
        // Modals
        showAddRewardModal: false,
        showCodeDetailsModal: false,
        showDeleteCodeModal: false,
        showCodeCreatedModal: false,
        
        // Created code
        createdCode: ''
    },
    
    computed: {
        // Check if can add reward
        canAddReward() {
            if (!this.newReward.type) return false;
            
            if (this.newReward.type === 'money') {
                return this.newReward.subtype && this.newReward.amount > 0;
            } else if (this.newReward.type === 'item') {
                if (this.newReward.name === 'other') {
                    return this.newReward.customName && this.newReward.customName.trim() !== '' && this.newReward.amount > 0;
                }
                return this.newReward.name && this.newReward.amount > 0;
            } else if (this.newReward.type === 'vehicle') {
                if (this.newReward.model === 'other') {
                    if (!this.newReward.customModel || this.newReward.customModel.trim() === '') return false;
                } else if (!this.newReward.model) {
                    return false;
                }
                
                if (this.newReward.hasCustomPlate) {
                    return this.newReward.plate && this.newReward.plate.length === 6;
                }
                return true;
            }
            
            return false;
        },
        
        // Check if can generate code
        canGenerateCode() {
            return this.newCode.rewards.length > 0 && 
                   this.newCode.description.trim() !== '' && 
                   this.newCode.usageLimit > 0;
        }
    },
    
    methods: {
        // Close UI
        closeUI() {
            this.showUI = false;
            fetch('https://kp-radeem/closeUI', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
        },
        
        // Add reward to cart
        addReward() {
            let reward = {
                type: this.newReward.type
            };
            
            if (this.newReward.type === 'money') {
                reward.subtype = this.newReward.subtype;
                reward.amount = parseInt(this.newReward.amount);
            } else if (this.newReward.type === 'item') {
                if (this.newReward.name === 'other') {
                    const customName = this.newReward.customName.trim();
                    if (!customName || customName.length < 1) {
                        return; // Validation should prevent this, but safety check
                    }
                    reward.name = customName;
                    reward.label = customName;
                } else {
                    reward.name = this.newReward.name;
                    // Find the label for display
                    const item = this.itemList.find(i => i.name === this.newReward.name);
                    if (item) {
                        reward.label = item.label;
                    }
                }
                reward.amount = parseInt(this.newReward.amount);
            } else if (this.newReward.type === 'vehicle') {
                if (this.newReward.model === 'other') {
                    const customModel = this.newReward.customModel.trim();
                    if (!customModel || customModel.length < 1) {
                        return; // Validation should prevent this, but safety check
                    }
                    reward.model = customModel;
                    reward.name = customModel;
                    reward.label = customModel;
                } else {
                    reward.model = this.newReward.model;
                    // Find the label for display
                    const vehicle = this.vehicleList.find(v => v.model === this.newReward.model);
                    if (vehicle) {
                        reward.label = vehicle.label;
                    }
                }
                
                if (this.newReward.hasCustomPlate) {
                    reward.plate = this.newReward.plate.toUpperCase();
                }
            }
            
            this.newCode.rewards.push(reward);
            this.showAddRewardModal = false;
            
            // Reset new reward form
            this.newReward = {
                type: '',
                subtype: 'cash',
                name: '',
                model: '',
                amount: 1,
                hasCustomPlate: false,
                plate: '',
                customName: '',
                customModel: ''
            };
        },
        
        // Remove reward from cart
        removeReward(index) {
            this.newCode.rewards.splice(index, 1);
        },
        
        // Generate redemption code
        generateCode() {
            fetch('https://kp-radeem/createCode', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(this.newCode)
            });
            
            // Reset form
            this.newCode = {
                rewards: [],
                description: '',
                usageLimit: 1
            };
        },
        
        // View code details
        viewCodeDetails(code) {
            this.selectedCode = code;
            this.showCodeDetailsModal = true;
        },
        
        // Show delete confirmation
        showDeleteModal(code) {
            this.selectedCode = code;
            this.deleteReason = '';
            this.showDeleteCodeModal = true;
        },
        
        // Delete code
        deleteCode() {
            fetch('https://kp-radeem/deleteCode', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    code: this.selectedCode.code,
                    reason: this.deleteReason
                })
            });
            
            this.showDeleteCodeModal = false;
        },
        
        // Format date
        formatDate(dateString) {
            const date = new Date(dateString);
            return date.toLocaleString();
        },
        
        // Get reward type label
        getRewardTypeLabel(reward) {
            if (reward.type === 'money') {
                let type = reward.subtype;
                if (type === 'cash') return 'Cash';
                if (type === 'bank') return 'Bank';
                if (type === 'black_money') return 'Black Money';
                return 'Money';
            } else if (reward.type === 'item') {
                return 'Item';
            } else if (reward.type === 'vehicle') {
                return 'Vehicle';
            }
            return 'Unknown';
        },
        
        // Get reward details
        getRewardDetails(reward) {
            if (reward.type === 'money') {
                return `$${reward.amount}`;
            } else if (reward.type === 'item') {
                return `${reward.label || reward.name} x${reward.amount}`;
            } else if (reward.type === 'vehicle') {
                let details = reward.label || reward.model || reward.name;
                if (reward.plate) {
                    details += ` (Plate: ${reward.plate})`;
                }
                return details;
            }
            return '';
        },
        
        // Load item list
        loadItemList() {
            fetch('https://kp-radeem/getItemList', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            })
            .then(response => response.json())
            .then(data => {
                this.itemList = data;
            });
        },
        
        // Load vehicle list
        loadVehicleList() {
            fetch('https://kp-radeem/getVehicleModels', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            })
            .then(response => response.json())
            .then(data => {
                this.vehicleList = data;
            });
        },
        
        // Reset custom fields when reward type changes
        resetCustomFields() {
            this.newReward.customName = '';
            this.newReward.customModel = '';
        }
    },
    
    // Watchers
    watch: {
        'newReward.type': function() {
            this.resetCustomFields();
        }
    },
    
    // Lifecycle hooks
    mounted() {
        // Load item and vehicle lists
        this.loadItemList();
        this.loadVehicleList();
        
        // Listen for NUI messages
        window.addEventListener('message', (event) => {
            const data = event.data;
            
            if (data.action === 'openAdminUI') {
                this.showUI = true;
                this.activeTab = 'create';
            } else if (data.action === 'updateCodes') {
                this.codes = data.codes;
            } else if (data.action === 'codeCreated') {
                this.createdCode = data.code;
                this.showCodeCreatedModal = true;
            } else if (data.action === 'codeDeleted') {
                // If the code is currently selected, close any open modals
                if (this.selectedCode && this.selectedCode.code === data.code) {
                    this.showCodeDetailsModal = false;
                    this.showDeleteCodeModal = false;
                }
                
                // Remove the code from the list
                this.codes = this.codes.filter(code => code.code !== data.code);
            }
        });
    }
});