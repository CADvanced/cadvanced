var app = new Vue({
    el: '#app',
    data: {
        display: false,
        user: {},
        units: []
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
                    this.units = item.units;
                } else if (item.type == 'user') {
                    this.user = item.user;
                }
            }
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
