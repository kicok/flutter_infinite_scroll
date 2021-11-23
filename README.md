# Infinite scroll

- 스크롤을 무한

- final ScrollController \_scrollController = ScrollController();

```
ListView.builder(
   controller: \_scrollController,
   itemCount: photos.length + 1, // itemCount를 의도적으로 늘린다 (CircularProgressIndicator를 표시하기 위해)
```