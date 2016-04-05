defmodule Assignment3 do

  def run(url, pages, maxDepth, currentDepth) do
    HTTPoison.start
    links = %{url => false}
    tagCounts = followLoop(Map.keys(links), pages, maxDepth, links, %{})

    IO.puts "--------------------------------"
    IO.puts "GLOBAL COUNT"
    IO.puts "ROOT URL: #{url}\nMaxPages: #{pages}\t MaxDepth: #{maxDepth}\tCurrentDepth: #{currentDepth}"
    IO.puts "--------------------------------"
    for tag <- Map.keys(tagCounts) do
      IO.puts "#{tag} #{tagCounts[tag]}"
    end
  end

  def followLoop([], _, _, _, tagCount) do tagCount end
  def followLoop(_, 0, _, _, tagCount) do tagCount end
  def followLoop(_, _, 0, _, tagCount) do tagCount end

  def followLoop([link | link_tail], maxFollow, depthCounter, links, tagCounts) do

    tagCount = %{}

    # If the link has not been visited yet
    if !links[link] do
      IO.puts "--------------------------------"
      IO.puts "URL: #{link}\nDEPTH LIMIT: #{depthCounter}\tFOLLOW LIMIT: #{maxFollow}"
      IO.puts "--------------------------------"
      tags = WebStats.getTags(link)

      # Get new links and tag count then print out tag count
      [currentLinks, tagCount] = WebStats.parseHTML(tags, %{}, %{})

      keys = Map.keys(currentLinks) || []

      tagCount = followLoop(keys, maxFollow-1, depthCounter-1, mergeLinks(Map.keys(currentLinks), Map.put(links, link, true), currentLinks), merge(Map.keys(tagCount), tagCounts, tagCount))
    end

    # Continue traversing through links
    followLoop(link_tail, maxFollow, depthCounter, Map.put(links, link, true), tagCount)
  end

  def startOn(url, args \\ []) do
      pages = args[:maxPages] || 10
      depth = args[:maxDepth] || 3
      run(url, pages, depth, 0)
  end

  def merge([], map1, _) do map1 end

  def merge([tag|tagList], map1, map2) do
    if Map.has_key?(map1, tag) do
        merge(tagList, Map.put(map1, tag, map1[tag] + map2[tag]), map2)
    else
        merge(tagList, Map.put(map1, tag, map2[tag]), map2)
    end
  end

  def mergeLinks([], map1, _) do map1 end

  def mergeLinks([link|links], map1, map2) do
    mergeLinks(links, Map.put(map1, link, map1[link] || map2[link]), map2)
  end

  def main(args) do end

end
