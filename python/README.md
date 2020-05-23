# Python API CLI

## Organization
This folder is organized into two sections

1) A Python package `api`, accessed as a layer by AWS Lambda

2) And API entrypoint for the API Proxy Lambda (`main.py`)

The top-level `scripts/make_api_layer.sh` packages a source code
wheel into a AWS-layer compatible zip file. The terraform code uploads
that zip file to make the package available to Lambda instances. All
dependencies in the `requirements.txt` will be pacakged alongside the
api package and available in the Lambda runtime. The API layer
entrypoint is the standalone `main.py` file, which connects the API
gateway to the api functions.

## Distribution
Create the layer zip archive (`zip/api.zip`):
```bash
./scripts/make_api_layer.sh
```

Install the `api` python package locally:
```bash
# install normally
pip3 install --user .

# install development mode (while in python/ folder)
pip3 install -e .

# check if api is installed
pip3 list | grep api

# check that installed api imports expected namespaces
python3 -c "import api; print(dir(api))"
```

## Functionality
The `main.py` entrypoint file is the top-level handler for API logic.
That script checks the request path and method before routing
application logic to one of the `api.functions`.

An individual function in `api.functions` should probably map to
a unique `(path, method)` pair.

Custom exceptions and external logic are separated from the individual
function handler code. Exceptions can be organized in heirarchies and
handled either as groups or individually in the `main.py` file or in the
function files. The ordering of exception handling matters, and will be
caught in the first matching statement.

Logging is being done with with the standard Python `logging` library.
Using `logging.info()` or `logging.error()` is usually sufficient, but
the documentation is online if you want to know more.

## Testing

I think you can run Python tests without dev-installing the Python
package, but you should probably do it anyways:
```bash
pip3 install -e .
```

You should test the api functions in `test`  on their own before
changing or uploading `main.py` to the dev/prod API Gateways:
```bash
python3 -m unittest discover
```

You should upload the terraform code to the dev api for testing the
`main.py` + api package together (probably check with Max before
doing this, multiple people uploading resources to AWS at the same
time will cause problems):
```bash
cd ../terraform/dev/lambda
terraform plan
terraform apply
```

