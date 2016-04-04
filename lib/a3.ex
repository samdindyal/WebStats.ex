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
      cascade = cascadeTagCounts(@tagCount, tagCount)
      if cascade != [] do
          [@tagCount | _] = cascade
      end

      followLoop(Map.keys(links), pages, maxDepth, currentDepth)
    end

    if (currentDepth == 0) do
      IO.puts "--------------------------------"
      IO.puts "GLOBAL COUNT"
      IO.puts "ROOT URL: #{url}\nMaxPages: #{pages}\t MaxDepth: #{maxDepth}\tCurrentDepth: #{currentDepth}"
      IO.puts "--------------------------------"

      for tag <- Map.keys(@tagCount) do
        IO.puts "#{tag}"
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

  def cascadeTagCounts(map1, map2) do
    for tag <- Map.keys(map2) do
      if Map.has_key?(map1, tag) do
        sum = (map1[tag]) + (map2[tag])
        map1 = Map.put(map2, tag, sum)
      else
        map1 = Map.put(map1, tag, 1)
      end
      map1
    end
  end

  def main(args) do end
end
