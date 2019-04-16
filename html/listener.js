var app = new Vue({
    el: '#app',
    data: {
        display: false,
        user: {},
        units: [],
        displayUnits: []
    },
    methods: {
        processMessage: function() {
            const item = event.data;
            if (item !== undefined) {
                if (item.type === 'toggle') {
                    if (item.toToggle === 'cad') {
                        this.display = !this.display;
                    }
                } else if (item.type == 'units') {
                    this.units = item.units.data.allUnits;
                } else if (item.type == 'user') {
                    this.user = item.user.data.getUser;
                    this.calculateUserUnits();
                }
            }
        },
        calculateUserUnits: function() {
            this.displayUnits = this.units.filter(unit => {
                const isInUnit = unit.users.find(
                    user => user.id === this.user.id
                );
                return isInUnit ? true : false;
            });
        }
    },
    created: function() {
        window.addEventListener('message', event => this.processMessage(event));
    },
    destroyed: function() {
        window.removeEventListener('message', event =>
            this.processMessage(event)
        );
    }
});
