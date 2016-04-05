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
    tagCounts = %{}

    if tags != nil && currentDepth < maxDepth - 1 do
      [links, tagCount] = WebStats.parseHTML(tags, %{}, %{})
      tagCounts = merge(Map.keys(tagCount), tagCounts, tagCount)

      followLoop(Map.keys(links), pages, maxDepth, currentDepth, links)
    end

    if (currentDepth == 0) do
      IO.puts "--------------------------------"
      IO.puts "GLOBAL COUNT"
      IO.puts "ROOT URL: #{url}\nMaxPages: #{pages}\t MaxDepth: #{maxDepth}\tCurrentDepth: #{currentDepth}"
      IO.puts "--------------------------------"
      for tag <- Map.keys(tagCounts) do
        IO.puts "#{tag} #{tagCounts[tag]}"
      end
    end
  end

  def followLoop([], _, _, _, _) do end

  def followLoop(_, 0, _, _, _) do end

  def followLoop([link | link_tail], maxFollow, maxDepth, currentDepth, links) do
    if !links[link] do
      run(link, maxFollow, maxDepth, currentDepth+1)
    end
    followLoop(link_tail, maxFollow-1, maxDepth, currentDepth, Map.put(links, link, true))
  end

  def startOn(url, args \\ []) do
      pages = args[:maxPages] || 10
      depth = args[:maxDepth] || 3
      run(url, pages, depth, 0)
  end

  def merge([], map1, _) do
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
