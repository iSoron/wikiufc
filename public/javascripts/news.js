events['.div_news .title a:click'] = function(element, e) {
    Effect.toggle(element.up().next(), 'blind');
    Event.stop(e);
}
