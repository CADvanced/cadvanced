Vue.component('call', {
    props: ['call'],
    template: `
        <div class="callDisplay">
            <p>Info: {{call.callerInfo}}</p>
            <p>Type: {{call.callType.name}}</p>
            <p>Grade: {{call.callGrade.name}}</p>
            <p>Incidents: {{call.callIncidents.map(inc => inc.name).join(', ')}}</p>
            <p>Locations: {{call.callLocations.map(inc => inc.name).join(', ')}}</p>
            <div>
                Descriptions:
                <p v-bind:key="description.id" v-for="description in call.callDescriptions" v-bind:description="description">
                    {{ description.text }}
                </p>
            </div>
        </div>`
});

Vue.component('unit', {
    props: ['unit'],
    template: `
        <div class="unitDisplay">
            <h3 v-bind:style="{ color: '#' + unit.unitState.colour }">{{ unit.callSign }} - {{ unit.unitType.name }}</h3>
            <call v-if="unit.assignedCalls.length > 0" v-bind:key="call.id" v-for="call in unit.assignedCalls" v-bind:call="call"></call>
            <div v-if="unit.assignedCalls.length == 0" class="noCallDisplay">No assigned calls</div>
        </div>`
});

Vue.component('unitsDisplay', {
    props: ['units'],
    template: `
        <div id="unitsDisplay">
            <unit v-for="unit in units" v-bind:key="unit.id" v-bind:unit="unit"></unit>
        </div>`
});

Vue.component('userDisplay', {
    props: ['user'],
    template: `
        <div id="userDisplay">
            <h2>Officer: {{ user.userName }}</h2>
        </div>`
});

Vue.component('terminal', {
    props: ['user', 'units'],
    template: `
        <div id="terminal">
            <h1>TERMINAL</h1>
            <div id="mainDisplay">
                <userDisplay v-bind:user="user"></userDisplay>
                <unitsDisplay v-bind:units="units"></unitsDisplay>
            </div>
        </div>`
});

var app = new Vue({
    el: '#app',
    template:
        '<terminal v-if="display" v-bind:user="user" v-bind:units="displayUnits"></terminal>',
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
                    this.units = item.units.data.allUnits;
                } else if (item.type == 'user') {
                    this.user = item.user.data.getUser;
                }
            }
        }
    },
    computed: {
        // Filter the displayed units to only those that the
        // user belongs to
        displayUnits: function() {
            return this.units.filter(unit => {
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
