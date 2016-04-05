defmodule WebStats do

  def getTags(url) do

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: _}}
       ->
        Regex.scan(~r/<[a-zA-Z][^<>]*>/, body)
      {:ok, %HTTPoison.Response{status_code: 301, body: body, headers: _}} ->
        Regex.scan(~r/<[a-zA-Z][^<>]*>/, body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
        []
      _ ->
        IO.puts "An error has occurred!"
        []
    end
  end

  def printTagCount(tagCount, links) do
    for tag <- Map.keys(tagCount) do
        IO.puts "#{tag} #{tagCount[tag]}"
    end
  end

  def parseHTML([], tagCount, links) do
    printTagCount(tagCount, links)
    [links, tagCount]
  end

  def parseHTML([tags_head | tags_tails], tagCount, links) do

    [full_tag | _] = tags_head
    scan = Regex.scan(~r/<([A-Za-z]+)/, full_tag)
    [[_ | [tag | _]]|_] = scan
    if tag == "a" && Regex.match?(~r/href="((http|https):\/\/[^"]*)"/, full_tag) do
      scan = Regex.scan(~r/href="((http|https):\/\/[^"]*)"/, full_tag)
      [[_head|[link|_tail]]|_] = scan
      links = Map.put(links, link, false)
    end
    parseHTML(tags_tails, updateCount(tag, tagCount), links)
  end

  def updateCount(tag, tagCount) do
    if Map.has_key?(tagCount, tag) do
        tagCount = %{ tagCount | tag => tagCount[tag] + 1}
    else
        tagCount = Map.put(tagCount, tag, 1)
    end
  end
end
