



## SQY

```
create layout #mylayout;
```

```
create field #myfield at *;
create field #myfield at A1..B2;
create field #myfield at A1;
create field at A1;
```

```
set grid to G5;
set debug to false;
set debug to true;
```

```
set $foobar to 'some text';
set $foobar to +1.2334;
```

```
select fields #myfield, #thatone, A1..B2;
select fields #myfield;
select fields #myfield;
select fields #myfield;
select fields #myfield;
select fields #myfield;
select fields #myfield;
select fields D12..E34, AA11;
select fields D12..E34,AA11;
select fields D3..E6;
select fields D3;
```

```
set all border to 'thin, blue';
set all borders to 'thin';
set all borders to 'thin, blue';
set all, bottom border to 'thin, blue';
```

```
set top, bottom border to 'thin, blue';
set top, bottom borders to 'thin, blue';
```

```
set top border of #thatfield to 'thick';
set top border of C3 to 'thin, blue';
set top border of C3, D4 to 'red';
set top border to 'thin, blue';
set top border to 'thin, blue';
set top border to 'thin, blue';
```

<!-- insert railroad here -->
