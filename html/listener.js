var app = new Vue({
    el: '#app',
    data: {
        display: false,
        cadData: {}
    },
    methods: {
        processMessage: function() {
            const item = event.data;
            if (item !== undefined) {
                if (item.type === 'data') {
                    const update = JSON.parse(item.data);
                    this.cadData = update.data.getUser;
                } else if (item.type === 'toggle') {
                    if (item.toToggle === 'cad') {
                        this.display = !this.display;
                    }
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
