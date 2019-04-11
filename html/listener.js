$(function() {
    window.addEventListener('message', event => {
        const item = event.data;
        if (item !== undefined && item.type === 'data') {
            const update = JSON.parse(item.data);
            const out = update.data.getUser.units.map(unit => unit.callSign);
            $('#container').text('Units: ' + out.join(', '));
        }
    });
});
