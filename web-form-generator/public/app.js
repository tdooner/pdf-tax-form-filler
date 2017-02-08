(function() {
  'use strict';

  let STATE;
  const transition = (newState) => {
    for (const el of document.querySelectorAll('.state-container')) {
      el.style = 'display: none';
    }
    document.querySelector('#state-' + newState).style = '';

    STATE = newState;
  };

  document.addEventListener('DOMContentLoaded', () => {
    transition('upload');
  });
})();
