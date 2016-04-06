defmodule Assignment3 do

  def run(url, pages, maxDepth, currentDepth) do
    HTTPoison.start

    {:ok, linkAgent} = Agent.start_link fn -> [] end
    {:ok, tagAgent} = Agent.start_link fn -> [] end

    Agent.update(linkAgent, fn links -> %{url => false} end)
    Agent.update(tagAgent, fn tagCount -> %{} end)

    links = Agent.get(linkAgent, fn links -> links end)
    followLoop(Map.keys(links), pages, maxDepth, linkAgent, tagAgent)
    tagCount = Agent.get(tagAgent, fn tagCounts -> tagCounts end)

    IO.puts "--------------------------------"
    IO.puts "GLOBAL COUNT"
    IO.puts "ROOT URL: #{url}\nMaxPages: #{pages}\t MaxDepth: #{maxDepth}\tCurrentDepth: #{currentDepth}"
    IO.puts "--------------------------------"
    WebStats.printTagCount(tagCount)

  end

  def followLoop([], _, _, _, _) do end
  def followLoop(_, 0, _, _, _) do end
  def followLoop(_, _, 0, _, _) do end

  def followLoop([link | link_tail], maxFollow, depthCounter, linkAgent, tagAgent) do

    # If the link has not been visited yet
    links = Agent.get(linkAgent, fn links -> links end)
    if !links[link] do
      IO.puts "--------------------------------"
      IO.puts "URL: #{link}\nDEPTH LIMIT: #{depthCounter}\tFOLLOW LIMIT: #{maxFollow}"
      IO.puts "--------------------------------"
      tags = WebStats.getTags(link)

      # Get new links and tag count then print out tag count
      [currentLinks, tagCount] = WebStats.parseHTML(tags, %{}, %{})

      Agent.update(tagAgent, fn tagCounts -> merge(Map.keys(tagCount), tagCounts, tagCount) end)
      Agent.update(linkAgent, fn links -> mergeLinks(Map.keys(currentLinks), Map.put(links, link, true), currentLinks) end)
      keys = Map.keys(currentLinks) || []
      followLoop(keys, maxFollow-1, depthCounter-1, linkAgent, tagAgent)
    end
    followLoop(link_tail, maxFollow, depthCounter, linkAgent, tagAgent)
  end

  def startOn(url, args \\ []) do
      pages = args[:maxPages] || 2
      depth = args[:maxDepth] || 2
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

  def main(args) do
    Assignment3.startOn("http://cps506.sarg.ryerson.ca")
  end

end
