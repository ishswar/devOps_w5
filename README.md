# devOps_w5
Microservices and Vagrant

### Over all archetecutre 

![alt text](Vagrant-DevOps.png)

### Provisioner script 


``` SHELL

  ~ ➜  ~ curl -i localhost:8090/get/a.txt
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 514
Date: Wed, 19 Jun 2019 21:37:40 GMT

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec id ipsum nec sapien mattis commodo et at nulla. Proin semper blandit varius. Etiam congue est sit amet magna hendrerit, luctus euismod mi tempor. Suspendisse scelerisque aliquam tellus non fringilla. Maecenas laoreet sed nulla id fermentum. Aliquam sed neque eget lorem malesuada aliquam. Nullam rhoncus lectus eu enim egestas consectetur. Aenean at nunc nec orci ultricies scelerisque vel vel nulla. Maecenas iaculis ante sed neque consequat dictum.



➜  ~ curl -i localhost:8090/get/b.txt
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 643
Date: Wed, 19 Jun 2019 21:37:43 GMT

Nunc ultricies tempus purus non vulputate. Quisque pretium rutrum velit, eu porttitor lorem elementum id. Maecenas vulputate lobortis libero, eget luctus erat consequat sed. Duis sodales ullamcorper elit, sed ultrices eros eleifend a. Nulla hendrerit leo at orci commodo pulvinar. Nunc ultrices aliquam turpis, quis hendrerit felis. Pellentesque tristique, sapien sit amet condimentum tempor, neque metus viverra leo, sit amet volutpat metus massa vitae lorem. Nunc suscipit tristique massa. Pellentesque dignissim justo id eros commodo ultricies. Cras sed nunc dictum, laoreet felis vel, imperdiet elit. Cras placerat feugiat sem at maximus.


➜  ~ curl -i localhost:8090/get/c.txt
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 822
Date: Wed, 19 Jun 2019 21:37:45 GMT

Phasellus leo erat, consectetur at velit quis, ultrices suscipit nisi. Sed tortor nisl, dapibus id vulputate id, mollis nec ex. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed nec est dolor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam erat volutpat. Suspendisse laoreet lobortis arcu, in mollis ex aliquam at. Aenean feugiat metus eget nisi interdum, nec vestibulum dolor sagittis. Mauris fringilla efficitur tincidunt. Nunc convallis venenatis sodales. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Praesent in elit a orci facilisis imperdiet a at libero. Aliquam diam ante, consectetur ultrices pulvinar auctor, dapibus ultrices augue. Morbi lorem elit, vestibulum sit amet nulla non, pulvinar dapibus sem.


➜  ~ curl -i localhost:8090/get/d.txt
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 793
Date: Wed, 19 Jun 2019 21:37:48 GMT

Sed pharetra mauris quis sapien ornare, eget fringilla est sodales. Donec vitae pellentesque dolor, et fermentum erat. Nullam rutrum diam ac posuere condimentum. Aenean sit amet interdum sem. Morbi faucibus ipsum eget felis vulputate suscipit. Nulla facilisi. Nullam interdum ligula in nunc vestibulum, eget vulputate felis finibus. Proin sed lobortis turpis.

Quisque eleifend quam nec laoreet interdum. Vestibulum accumsan tristique efficitur. Vestibulum scelerisque nec nisi vitae vulputate. Praesent ultricies dignissim nibh, nec egestas quam facilisis nec. Phasellus ligula erat, elementum vitae volutpat in, pellentesque at nulla. Aliquam consectetur condimentum varius. Etiam maximus sapien dui, non tempus sem volutpat id. Praesent leo nibh, laoreet eget porta non, tincidunt at enim.


➜  ~ curl -i localhost:8090/get/foo.txt
HTTP/1.1 404 NOT FOUND
Content-Type: text/plain; charset=utf-8
Content-Length: 22
Date: Wed, 19 Jun 2019 21:37:52 GMT

File foo.txt NOT_FOUND%
```