(function() {
  'use strict';

  const formField = (name, label, type, options) => {
    if (type === 'Text') {
      return `
<input class="form-field" name="names[${name}]" value="${label}" />
<input class="form-field" name="fields[${name}]" value="${Math.floor(Math.random() * 1000)}" />
`;
    } else if (type === 'Button') {
      const optionInputs = (options || []).map(option => `${option} <input type="radio" name="fields[${name}]" value="${option}" />`);
      return `
<div>
<input class="form-field" name="names[${name}]" value="${label}" />
${optionInputs.join("\n")}
</div>
`;
    } else {
      return '<p>unknown type: ' + type + '</p>';
    }
  };

  const controllers = {
    viewpdf(args) {
      const [id] = args;
      const form = document.getElementById('fields-form')

      const replaceImages = (images) => {
        if (images === null) {
          document.getElementById('viewpdf-right').innerHTML = 'Rendering...';
          return;
        }

        document.getElementById('viewpdf-right').innerHTML =
          images.files.map((filename) => {
            return `<img src="/tmp/${images.dirname}/${filename}" />`;
          });
      };

      const renderForm = () => {
        replaceImages(null);

        fetch(`/api/render/${id}`, {
          method: 'POST',
          body: new FormData(document.getElementById('fields-form'))
        })
        .then(resp => resp.json())
        .then(json => replaceImages(json))
      };

      const saveNames = () => {
        fetch(`/api/fieldnames/${id}`, {
          method: 'POST',
          body: new FormData(document.getElementById('fields-form'))
        })
      };

      fetch(`/api/fields/${id}`).then((resp) => {
        resp.json().then((fields) => {
          form.innerHTML = fields.map(
            (field) => formField(
              field.FieldId,
              field.FieldHumanName || field.FieldName,
              field.FieldType,
              field.FieldStateOption
            )
          ).join('');

          form.addEventListener('change', (e) => {
            const changedField = e.target;

            // don't re-render the pdf if just the name is different
            if (changedField.name.indexOf("names") === 0) {
              saveNames();
            } else {
              renderForm();
            }
          });

          renderForm();
        });
      })
    },

    upload() {
      const renderLinks = (forms) => {
        document.getElementById('upload-existing').innerHTML =
          forms.map(form => `<a href="/form/${form}">${form}</a><br>`).join("");
      };

      fetch(`/api/forms`)
        .then(resp => resp.json())
        .then(renderLinks);
    },
  };

  let STATE, STATEARG;
  const transition = (newState, args) => {
    for (const el of document.querySelectorAll('.state-container')) {
      el.style = 'display: none';
    }
    document.querySelector('#state-' + newState).style = '';

    STATE = newState;
    controllers[STATE](args);
  };

  document.addEventListener('DOMContentLoaded', () => {
    const match = window.location.pathname.match(/\/form\/(\w+)/)
    if (match) {
      transition('viewpdf', [match[1]]);
    } else {
      transition('upload');
    }
  });
})();
