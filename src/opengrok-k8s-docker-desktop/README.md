# opengrok for localhost k8s deployment (using Docker Desktop's integrated Kubernetes cluster)

Opengrok is a FOSS code search engine and indexer.

These are Kubernetes manifests to help you deploy an Opengrok instance
on your local machine, specifically using Docker Desktop on macOS.
Docker Desktop has an integrated Kubernetes cluster that works very
well with minimal fuss.

# Usage

[Install ingress-nginx](https://kubernetes.github.io/ingress-nginx/deploy/#quick-start) on your Kubernetes cluster.

Edit the file `volumes.yaml` and replace the `hostPath.path` fields with absolute paths to directories on your machine.

Then `cd` into this directory and

```bash
kubectl apply -f .
```

## Making `http://opengrok.test` work

It's possible to access the cluster without port forwarding and using a nice domain name, like `http://opengrok.test`.

1. Install `dnsmasq`:
```bash
brew install dnsmasq
```

2. Set up `dnsmasq`:

```bash
cat <<EOF | tee $(brew --prefix)/etc/dnsmasq.d/local-dns.conf
address=/.test/127.0.0.1
EOF
```

3. Start the `dnsmasq` service

```bash
sudo brew services start dnsmasq
```

`dnsmasq` should now now run at login

4. Add your nameserver to macOS's resolvers

```bash
sudo mkdir -v /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'
```

5. Add your DNS server to the list of resolvers in Settings

Settings → WiFi → (choose your network) Details → DNS → Add "127.0.0.1" as the first DNS Server

6. Done! You should be able to open [http://opengrok.test](http://opengrok.test) in your browser. All managed by Kubernetes so no fiddling with init scripts to get it to run and stay alive.
