import shutil

import bentoml
from transformers import pipeline
from transformers import DistilBertTokenizerFast, DistilBertForSequenceClassification
from bentoml.adapters import JsonInput

import os
from bentoml.service.artifacts import BentoServiceArtifact


# Seems like bentoML dont handle correcty hf pipeline, so we need to implement our own artifact in order to cache the model
class HFPipelineArtifact(BentoServiceArtifact):
    def __init__(self, name):
        super(HFPipelineArtifact, self).__init__(name)
        self._model = None

    def pack(self, model, metadata=None):
        self._model = model
        return self

    def get(self):
        return self._model

    def save(self, dst):
        self._model.save_pretrained(dst)

    def load(self, path):
        model = pipeline('sentiment-analysis', tokenizer=DistilBertTokenizerFast.from_pretrained(path),
                         model=DistilBertForSequenceClassification.from_pretrained(path))
        return self.pack(model)


@bentoml.env(pip_packages=["transformers==4.11.3", "torch==1.9.0"])
@bentoml.artifacts([HFPipelineArtifact("classifier")])
class TransformerService(bentoml.BentoService):
    @bentoml.api(input=JsonInput(), batch=False)
    def predict(self, parsed_json):
        src_text = parsed_json.get("text")
        return self.artifacts.classifier(src_text)


if __name__ == '__main__':
    ts = TransformerService()
    classifier = pipeline('sentiment-analysis')
    ts.pack("classifier", classifier)
    output = "./output"
    if os.path.exists(output) and os.path.isdir(output):
        shutil.rmtree(output)
    os.mkdir("./output")
    ts.save_to_dir("./output")
