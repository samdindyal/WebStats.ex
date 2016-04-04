defmodule Assignment3 do

  @tagCount %{}
  @counter 0
  @links %{}

  def run(url, pages, maxDepth, currentDepth) do
    HTTPoison.start
    IO.puts "--------------------------------"
    IO.puts "URL: #{url}\nMaxPages: #{pages}\t MaxDepth: #{maxDepth}\tCurrentDepth: #{currentDepth}"
    IO.puts "--------------------------------"
    tags = WebStats.getTags(url)
    pagesFollowed = 0

    if tags != nil do
      [links, tagCount] = WebStats.parseHTML(tags, %{}, %{})
      cascadeTagCounts(tagCount)
      followLoop(Map.keys(links), pages, maxDepth, currentDepth)
    end
  end

  def followLoop([], _, _, _) do

  end

  def followLoop(_, 0, _, _) do

  end


  def followLoop([link | link_tail], maxFollow, maxDepth, currentDepth) do
    run(link, maxFollow, maxDepth, currentDepth+1)
    @links = Map.put(@links, link, true)
    followLoop([link_tail], maxFollow-1, maxDepth, currentDepth)
  end

  def startOn(url, args \\ []) do
      pages = args[:maxPages] || 3
      depth = args[:maxDepth] || 3
      run(url, pages, depth, 0)
  end

  def cascadeTagCounts(tagCount) do
      for tag <- Map.keys(tagCount) do
        if Map.has_key?(@tagCount, tag) do
            @tagCount = %{ @tagCount | tag => tagCount[tag] + @tagCount[tag] }
        else
            @tagCount = Map.put(@tagCount, tag, 1)
        end
      end
  end

  def main(args) do

  end
end
