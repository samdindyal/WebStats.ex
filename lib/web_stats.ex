defmodule WebStats do

  use HTTPoison.Base
  def getTags(url) do
    HTTPoison.get!(url)
    |> handleResponse
  end

  def handleResponse(response) do
    status_code = response.status_code
    case status_code do
      status_code when status_code in 200..299 -> Regex.scan(~r/<[a-zA-Z][^<>]*>/, response.body)
      status_code when status_code in 300..399 -> []
      status_code when status_code >= 400      -> []
    end
  end

  def printTagCount(tagCount) do
    links = Enum.sort(Map.keys(tagCount))
    for tag <- links do
        IO.puts "#{tag} #{tagCount[tag]}"
    end
  end

  def parseHTML([], tagCount, links) do
    printTagCount(tagCount)
    [links, tagCount]
  end

  def parseHTML([tags_head | tags_tails], tagCount, links) do

    [full_tag | _] = tags_head
    scan = Regex.scan(~r/<([A-Za-z]+)/, full_tag)
    [[_ | [tag | _]]|_] = scan
    tag = String.downcase(tag)
    if tag == "a" && full_tag =~ ~r/href="((http|https):\/\/[^"]*)"/ do
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
