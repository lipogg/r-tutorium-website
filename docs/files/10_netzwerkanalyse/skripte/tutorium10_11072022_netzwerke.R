# R Tutorium SoSe2022
# Einstieg Netzwerkanalyse in R
# Lisa Poggel
# 11.07.2022

## 1 Einstieg: rdracor 

# https://github.com/dracor-org/rdracor
install.packages(c("remotes", "igraph"))
remotes::install_github("Pozdniakov/rdracor")
library(rdracor)

corpora <- get_dracor_meta()
summary(corpora)
plot(corpora)

godunov <- play_igraph(corpus = "rus",
                       play = "pushkin-boris-godunov")
library(igraph)
edge_density(godunov)
diameter(godunov, weights = NA)
summary(godunov)

plot(godunov)

## 2 Netzwerke aus importierten Netzwerkdaten erstellen

setwd("/Users/gast/R-Tutorium/Korpora")

# Möglichkeit 1: graphml Datei als igraph-Objekt einlesen
net <- read_graph("ger000577-klemm-der-besuch.graphml", format="graphml")
# ab Zeile 70 weiter

# Möglichkeit 2: Knoten-und Kantenliste einlesen 
nodes <- read.csv("ger000577-klemm-der-besuch_nodes.csv", header=T, as.is=T) #nodelist ist cast list (list of characters)
edges <- read.csv("ger000577-klemm-der-besuch_edges.csv", header=T, as.is=T) #edgelist ist network data"


# Schauen wir uns die importierten Daten an: 
# Wie viele Knoten gibt es?
# Was sind ihre Attribute?
# Wie viele Kanten gibt es?
# Was sind ihre Attribute?

# Daten in ein igraph-Objekt konvertieren:
net <- graph_from_data_frame(d=edges, vertices=nodes, 
                             directed=FALSE) 
# Fehlermeldung: Some vertex names in edge list are not listed in vertex data frame
# Woran liegt das? 
?graph_from_data_frame
# Wir müssen also die zweite und dritte Spalte in der Edgelist tauschen. Das können wir 
# direkt im RStudio machen: 
edges_df <- read.csv("ger000577-klemm-der-besuch_edges.csv")
edges_df
edges_df <- edges_df[,c("Source", "Target", "Type", "Weight")]
edges_df # überprüfen
# neue Kantenliste speichern
write.csv(edges_df, "ger000577-klemm-der-besuch_edges.csv", quote=FALSE, row.names=FALSE) # alte Kantenliste überschreiben

# Kantenliste neu einlesen: 
edges <- read.csv("ger000577-klemm-der-besuch_edges.csv", header=T, as.is=T) 

# In ein igraph-Objekt konvertieren: 
net <- graph_from_data_frame(d=edges, vertices=nodes, 
                             directed=FALSE) 

# Dieser Befehl hat aus den Kanten- und Knotentabellen ein igraph-Objekt erstellt. 
# Dabei haben wir der Funktion graph_from_data_frame() das Argument "directed=FALSE" 
# übergeben. Was bedeutet das? 

# 3. Netzwerk zeichnen und anpassen
plot(net, edge.arrow.size=.4,vertex.label=NA)

# Änderungen, um das Netzwerk schöner zu machen 

n <- 20 # für die Knotengröße
col <- "yellow" # für die Knotenfarbe
# Knotengröße ändern
plot(net, edge.arrow.size=.4,vertex.label=NA, 
     vertex.size=n)

# Knotenfarbe ändern
plot(net, edge.arrow.size=.4,vertex.label=NA, 
     vertex.size=n, vertex.color=col)

# Beschriftung (Figurennamen) hinzufügen
plot(net, edge.arrow.size=.4,
     vertex.size=n, vertex.color=col,
     vertex.label=V(net)$name) # Figurennamen aus der Knotenliste auswählen

# Schrift verkleinern
plot(net, edge.arrow.size=.4,
     vertex.size=n, vertex.color=col,
     vertex.label=V(net)$name,
     vertex.label.cex=.6)

# Gekrümmte Kanten (edge.curved=.4) :
plot(net, edge.arrow.size=.4,
     vertex.size=n, vertex.color=col,
     vertex.label=V(net)$name.label,
     vertex.label.cex=.6, edge.curved=.4)

# Übung: Ändert die Knotengröße, Farbe und wählt ein anderes Attribut als Beschriftung

# 4. Netzwerkeigenschaften abrufen
?graph.density # ratio of number of edges and number of all possible edges, more generally: connected ties (cordinality)/total possible ties (size); or alternatively: number of edges (graph size)/number of nodes (graph order)
?mean_distance # average distance between vertices: this function calculates the shortest paths between all pairs of vertices
?diameter # length of the longest geodesic (number of edges in a shortest path)
?degree # degree of each vertex: the number of its adjacent edges
?betweenness # number of geodesics (shortest paths) going through a vertex or an edge
?eigen_centrality # calculates eigenvektor centralities of positions within the graph: eigenvektor centrality scores correspond to the values of the first eigenvector of the graph adjacency matrix
?closeness # calculates closeness centrality: how many steps (edges) are required to access every other vertex from a given vertex

# Dichte des Graphen berechnen
edge_density(net, loops=F) # loops=F schließt Schleifen aus der Berechnung aus (brauchen wir hier nicht!)
# Mittlere Pfadlänge berechnen (mean average path) 
mean_distance(net)

# Drei Namen mit höchster indegree centrality auflisten
# Indegree berechnen 
indeg <- degree(net, mode = "in",  # mode = "out" für outdegree centrality, "all" für gesamte Dichte
                   v = V(net), # V(net) ohne Zugriff auf eine spezielle Spalte bedeutet, dass ids verwendet werden
                   loops = TRUE, normalized = FALSE)

# Ergebnisse in einem Dataframe speichern
nodes["indegree"] = indeg
nodes$name[nodes$indegree >= 4] # Figuren mit indegree größer oder gleich 4 
nodes$name[max(nodes$indegree)] # Figur mit dem höchsten indegree Wert


# Graph mit Knotengröße nach Grad skaliert
plot(net, edge.arrow.size=.4,
     vertex.size=indeg, vertex.color=col,
     vertex.label=V(net)$name.label,
     vertex.label.cex=.6)

# Kantendicke nach Gewicht skalieren
plot(net, edge.arrow.size=.4,
     vertex.cex=.6, vertex.color="white",
     vertex.label=V(net)$name, vertex.label.cex = .6,
     edge.weight=2, edge.width=(E(net)$weight/5))

# 5. Netzwerklayout ändern

layout_1 <- layout_in_circle(net, order = V(net))
layout_2 <- layout_with_fr(net)

plot(net, edge.arrow.size=.4,
     vertex.cex=.6, vertex.color="white",
     vertex.label=V(net)$media, vertex.label.cex = .6,
     edge.weight=2, edge.width=(E(net)$weight/5),
     layout = layout_1)


# Übung: 
# 1) Listet drei Figuren mit der höchsten betweenness centrality
# 2) Ändert die Knotengröße, sodass sie nach der betweenness centrality skaliert ist
# 3) Recherchiert ein weiteres Layout und setzt es in die Funktion ein

# 6. Community Detection
# Tutorial mit verschiedenen Methoden zur Identifizierung von Communities:
# https://users.dimi.uniud.it/~massimo.franceschet/R/communities.html

layout_3 <- layout_with_fr(net)

# "greedy-Methode" anwenden 
c1 = cluster_fast_greedy(net)
modularity(c1)
# modularity matrix erstellen
B = modularity_matrix(net, membership(c1))
round(B[1,],2)
# Anzahl Communities
length(c1)
# Größe der Communities
sizes(c1)
# Communities mit Knotenfarbe unterscheiden
plot(net, edge.arrow.size=.4,
     vertex.size=n, vertex.color=membership(c1),
     vertex.label=V(net)$id,
     vertex.label.cex=.6, 
     layout=layout_3)
# Communities mit farbigem Hintergrund umrahmen 
plot(c1, net, edge.arrow.size=.4,
     vertex.size=n, vertex.color=membership(c1),
     vertex.label=V(net)$id,
     vertex.label.cex=.6, 
     layout=layout_3)


