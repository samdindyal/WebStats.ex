#WebStats Elixir


##Synopsis
This is a multithreaded, statistical web crawler written in Elixir.
Given an initial URL, this application will scan and keep track of all the start-tags of the initial webpage as well as its connecting pages. The final listing will show all the webpages visited, the total number of start-tags found on each page, as well as a sorted global count for each start tag.


##Installation
This application requires [Elixir](http://elixir-lang.org/install.html).



##Running the Application
To compile:

```
mix escript.build
```

To run, open the Elixir shell with the command:

```
iex -S mix
```

Then, enter the initial URL to be scanned, the maximum pages to visit, and the max depth by replacing **_url_**, **_pages_**, and **_depth_**, respectively:

```elixir
Assignment3.startOn("url", maxPages: pages, maxDepth: depth)
```

The maximum pages to navigate and the max depth is optional.

```elixir
Assignment3.startOn("url")
```

If no value is entered, then the maximum pages to navigate will have a default value of 10 and the maximum depth will have a default value of 3.
