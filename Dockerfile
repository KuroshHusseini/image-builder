FROM docker:25-git


COPY . .
RUN chmod +x ./builder.sh

ENTRYPOINT [ "./builder.sh" ]