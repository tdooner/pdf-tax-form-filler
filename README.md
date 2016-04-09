PDF Tax Form Filler
==================

![Example Tax Form Image](https://raw.githubusercontent.com/tdooner/pdf-tax-form-filler/master/example.png)

This is part my attempt to write tax preparation software for April 2017. This
repo contains the lower level of the abstraction -- the PDF form filling
library.

Installation
---------------
1. Install ruby
2. gem install prawn combine_pdf

Usage
---------------
Currently everything is hardcoded. Render the proof of concept:

```
ruby form.rb
```

Methodology
---------------
Unfortunately, tax forms in various jurisdictions vary too wildly to use
automated field detection. Furthermore, the landscape of PDF form filling
libraries is limited at best, with even leading tools like `pdftk` not
supporting fine-grained rendering options. Almost certainly, we will run into
forms that look terrible when filled with `pdftk fill_form`.

This approach is different. Instead of trying to use the existing form fields,
we simply composite two PDFs atop each other. Since this is a simple operation
(combining the objects), it is well-supported by various libraries.

The top PDF contains the form field values, and is rendered by Prawn. The bottom
PDF is the government-provided form. Then, we use a PDF watermark library
(the `combine_pdf` gem) to composite the form fills on top of the
government-provided form. Pdftk can do this too with the `background` command,
but for now the pure-ruby solution is easier to install and manage.
