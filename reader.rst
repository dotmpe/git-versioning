
.. raw:: html

  <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
  <script src="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.4/js/bootstrap.min.js"></script>

.. raw:: html

  <style type="text/css">
    body {
      position: relative;
      margin: 1.5em;
    }
    h1.title {
      margin-top: 5em;
    }
    .document {
      margin-right: 16.5em;
    }
    .contents.scrollspy {
      width: 14em;
      font-size: 9.00pt;
      position: fixed;
      padding: .5em 1em;
      overflow: scroll-y;
      top: 1em;
      right: 1em;
      background-color: white;
      border: 1px solid #efefef;
    }
    div.contents .nav {
      margin-left: 0.7em;
      margin-bottom: .2em;
    }
    div.contents .nav .nav,
    div.contents .nav .nav .nav { 
      display: none;
    }
    div.contents .nav .active > .nav {
      display: block;
    }
    div.contents a {
       color: grey;
    }
    div.contents .active > a {
      display: inline;
      color: black;
      border-bottom: 1px solid blue;
    }
  </style>

  <script type="text/javascript">
    $(document).ready(function() {
      console.log('Ready');

      var nav = $('div.contents > ul.simple');
      nav.find('ul').attr('class','nav');
      nav.attr('class', 'nav');

      $('.section#table-of-contents h1').remove();
      $("div.contents [href=#table-of-contents]").parent().remove();

      $('body').scrollspy({
        offset: $(window).height() / 2.4,
        target: 'div.contents'
      });

    });
  </script>


.. .. figure:: media/logo.png



Table of contents
=================

.. contents:: Table of contents
  :class: scrollspy


.. include:: ReadMe.rst



