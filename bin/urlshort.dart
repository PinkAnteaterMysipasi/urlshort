import 'package:alfred/alfred.dart';
import 'package:hive/hive.dart';
import 'dart:io';

late final Box<String> urls;

void main (List<String> args) async {
  Hive.init(Directory.current.path);
  urls = await Hive.openBox('urls');
  await app.listen(int.parse(args.first));
}

final app = Alfred()
  ..get('/', (req, res) async {
    await res.html('''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>URLs</title>
</head>
<body>
  <form action="/" method="post">
      <input type="text" name="id" placeholder="id">
      <br>
      <input type="url" name="url" placeholder="url">
      <br>
      <input type="submit" value="OK">
  </form>
</body>
</html>
  ''');
  })
  ..get('/:id', (req, res) async {
    await res.found(urls.get(req.params['id']) ?? '/');
  })
  ..post('/', (req, res) async {
    final body = await req.bodyAsJsonMap;
    await urls.put(body['id'], body['url']);
    await res.found('/');
  });

extension on HttpResponse {
  Future html(String html) {
    headers.contentType = ContentType.html;
    write(html);
    return close();
  }
  Future found(String location) {
    headers.set('location', location);
    statusCode = 302;
    return close();
  }
}