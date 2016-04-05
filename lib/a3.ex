defmodule Assignment3 do

  @tagCount %{}
  @links %{}

  def run(url, pages, maxDepth, currentDepth) do
    HTTPoison.start
    IO.puts "--------------------------------"
    IO.puts "URL: #{url}\nMaxPages: #{pages}\t MaxDepth: #{maxDepth}\tCurrentDepth: #{currentDepth}"
    IO.puts "--------------------------------"
    tags = WebStats.getTags(url)
    pagesFollowed = 0

    if tags != nil && currentDepth < maxDepth - 1 do
      [links, tagCount] = WebStats.parseHTML(tags, %{}, %{})
      tagCount = merge(Map.keys(tagCount), @tagCount, tagCount)

      followLoop(Map.keys(links), pages, maxDepth, currentDepth)
    end

    if (currentDepth == 0) do
      IO.puts "--------------------------------"
      IO.puts "GLOBAL COUNT"
      IO.puts "ROOT URL: #{url}\nMaxPages: #{pages}\t MaxDepth: #{maxDepth}\tCurrentDepth: #{currentDepth}"
      IO.puts "--------------------------------"

      for tag <- Map.keys(tagCount) do
        IO.puts "#{tag} tagCount[tag]"
      end
    end
  end

  def followLoop([], _, _, _) do end

  def followLoop(_, 0, _, _) do end

  def followLoop([link | link_tail], maxFollow, maxDepth, currentDepth) do
    run(link, maxFollow, maxDepth, currentDepth+1)
    @links = Map.put(@links, link, true)
    followLoop(link_tail, maxFollow-1, maxDepth, currentDepth)
  end

  def startOn(url, args \\ []) do
      pages = args[:maxPages] || 10
      depth = args[:maxDepth] || 3
      run(url, pages, depth, 0)
      @tagCount
  end

  def merge([], map1, map2) do
  map1
  end
  def merge([tag|tagList], map1, map2) do
    if Map.has_key?(map1, tag) do
        merge(tagList, Map.put(map1, tag, map1[tag] + map2[tag]), map2)
    else
        merge(tagList, Map.put(map1, tag, map2[tag]), map2)
    end
  end

  def main(args) do end
end
