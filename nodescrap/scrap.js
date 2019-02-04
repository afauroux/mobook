const rp = require("request-promise");
const $ = require("cheerio");
const url =
  "http://www.litteratureaudio.com/notre-bibliotheque-de-livres-audio-gratuits?pg=";
var pages = []; //new Array(20);
for (var i = 0; i < 2; i++) {
  pages[i] = url + (i + 1);
}

async function getBook(title, href) {
  var html = await rp(href);
  var mp3 = [];
  try {
    mp3.push($(".link-roman-mp3-file", html));
  } catch (err) {
    console.log("err :", err);
  }
  try {
    mp3.push($(".link-mp3-file", html));
  } catch (err) {
    console.log("err :", err);
  }

  return { title, mp3 };
}

async function scrapBibliPage(page) {
  var html = await rp(page);
  var div = $(".ddsg-wrapper > ul", html);
  var sections = div[0].children;

  var books = [];
  for (var i in sections) {
    var head = sections[i];
    var booklist = $("ul > li > font > a", head);

    for (var i in booklist) {
      try {
        console.log(booklist[i].attribs.title, booklist[i].attribs.href);
        books.push(
          getBook(booklist[i].attribs.title, booklist[i].attribs.href)
        );
      } catch (err) {
        console.log("err :", err);
      }
    }
  }

  return books;
}
async function main() {
  var books = [];
  for (var i in pages) {
    books.push(scrapBibliPage(pages[i]));
  }
  var books = await Promise.all(books);
  return books;
}
main().then(books => console.log("books :", books));

async function main2() {
  var categ = [];
  var i = 0;
  pages.forEach(page => {
    rp(page)
      .then(function(html) {
        //success!
        var div = $(".ddsg-wrapper > ul", html);
        var sections = div[0].children[1].children;

        // the category name is in child 1 or 2
        // and the list of books is the next and last child
        var categName = sections[sections.length - 2].childNodes[0].data;
        var bookList = sections[sections.length - 1].childNodes;
        console.log(categName);
        for (var book of bookList) {
          var attribs = $("font > a", book)[0].attribs;
          var title = attribs["title"];
          var href = attribs["href"];
          var getBook = function(html) {
            //closure which retrieve book infos
            //and mp3 links from each book page
            console.log(title);
            console.log(href);
          };
          rp(href).then(getBook(html));
        }
        //console.log(categ);
      })
      .catch(function(err) {
        //handle error
        console.log(err);
      });
  });

  console.log("im here");
}
