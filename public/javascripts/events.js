events['.div_calendario .title a:click'] = function(element, e) {
    Effect.toggle(element.up().next(), 'blind');
    Event.stop(e);
}
